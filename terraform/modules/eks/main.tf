#############################
# VARs
#############################

locals {
  cluster_name = "${var.project_name}-${var.stage}-eks"
  vpc_name     = "${var.project_name}-${var.stage}-vpc"
}

#############################
# Providers
#############################

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.stage
      Project     = "web-crawler-on-eks"
    }
  }
}
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}
data "aws_eks_cluster_auth" "cluster_auth" {
  name = local.cluster_name
}

#############################
# EKS
#############################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name        = local.cluster_name
  cluster_version     = "1.30"
  authentication_mode = "API_AND_CONFIG_MAP"

  # for higher security requirements: use false and add a bastion host that is in a public subnet of this VPC, 
  # and add this bastion host to the NACL of the private subnets
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
    }
  }
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

}


data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "kubernetes_config_map" "aws_auth_configmap_custom" {

  metadata {
    name      = "aws-auth-custom"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
- rolearn: arn:aws:iam::${var.account_id}:role/AdminAccessRole
  username: admin
  groups:
    - system:masters
- rolearn: arn:aws:iam::${var.account_id}:role/AmazonEKSConnectorAgentRole
  username: reader
  groups:
    - reader
YAML
    mapUsers = <<YAML
- rolearn: arn:aws:iam::${var.account_id}:role/admin
  username: reader
  groups:
    - reader
- rolearn: arn:aws:iam::${var.account_id}:user/askill
  username: askill
  groups:
    - system:masters
YAML
  }
}

// https://docs.aws.amazon.com/eks/latest/userguide/view-kubernetes-resources.html#view-kubernetes-resources-permissions
// create EKSViewResourcesPolicy
// from: https://stackoverflow.com/a/75935176
resource "aws_iam_policy" "eks_view_resources_policy" {
  name        = "EKSViewResourcesPolicy"
  description = "Policy to allow a principal to view Kubernetes resources for all clusters in the account"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:ListFargateProfiles",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:ListAddons",
          "eks:DescribeCluster",
          "eks:DescribeAddonVersions",
          "eks:ListClusters",
          "eks:ListIdentityProviderConfigs",
          "iam:ListRoles"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:*:${var.account_id}:parameter/*"
      }
    ]
  })
}


//https://docs.aws.amazon.com/eks/latest/userguide/connector_IAM_role.html
// create AmazonEKSConnectorAgentRole and AmazonEKSConnectorAgentPolicy
resource "aws_iam_role" "eks_connector_agent_role" {
  name = "AmazonEKSConnectorAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_connector_agent_policy" {
  name = "AmazonEKSConnectorAgentPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SsmControlChannel"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel"
        ]
        Resource = "arn:aws:eks:*:*:cluster/*"
      },
      {
        Sid    = "ssmDataplaneOperations"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenDataChannel",
          "ssmmessages:OpenControlChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_connector_agent_role.name
}

resource "aws_iam_role_policy_attachment" "eks_connector_agent_custom_policy_attachment" {
  policy_arn = aws_iam_policy.eks_connector_agent_policy.arn
  role       = aws_iam_role.eks_connector_agent_role.name
}

#############
# S3 access 
#############

resource "aws_iam_role" "optar_s3_cache_access_role" {
  name = "optar-s3-cache-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${module.eks.oidc_provider}"
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" : "system:serviceaccount:default:optar-s3-cache-service-account",
            "${module.eks.oidc_provider}:aud" : "sts.amazonaws.com"
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "optar_s3_cache_access_policy" {
  name        = "optar-s3-cache-access-policy"
  description = "allow eks services to access the optar bucket, ideally this would be specific to the single cronjob / services"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.app_cache_arn}",
          "${var.app_cache_arn}/*"
        ]
      }
    ]
  })

  depends_on = [aws_iam_role.optar_s3_cache_access_role]
}

resource "kubernetes_service_account" "optar_s3_cache_access_sa" {
  automount_service_account_token = true
  metadata {
    name      = "optar-s3-cache-service-account"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.optar_s3_cache_access_role.arn
    }
  }
}


resource "aws_iam_role_policy_attachment" "s3_access_attach" {
  role       = aws_iam_role.optar_s3_cache_access_role.name
  policy_arn = aws_iam_policy.optar_s3_cache_access_policy.arn
}


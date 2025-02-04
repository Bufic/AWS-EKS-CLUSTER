module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.eks_version
  vpc_id          = var.vpc_id

  create_iam_role = true # Default is true
  attach_cluster_encryption_policy = false  # Default is true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  control_plane_subnet_ids = var.subnet_ids

  create_cluster_security_group = true
  cluster_security_group_description = "EKS cluster security group"

  bootstrap_self_managed_addons = true
  authentication_mode = "API"
  enable_cluster_creator_admin_permissions = true
  dataplane_wait_duration = "40s"

  enable_security_groups_for_pods = true

  create_cloudwatch_log_group = false
  create_kms_key = false
  enable_kms_key_rotation = false
  kms_key_enable_default_policy = false
  enable_irsa = false
  cluster_encryption_config = {}
  enable_auto_mode_custom_tags = false

  cluster_addons = {
    vpc-cni = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    group1 = {
      name          = "fubara-eks-node-group"
      ami_type      = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      capacity_type = "SPOT"
      min_size      = 1
      max_size      = 2
      desired_size  = 1
    }
  }

  create_node_security_group = true
  node_security_group_enable_recommended_rules = true
  node_security_group_description = "EKS node group security group - used by nodes to communicate with the cluster API Server"
  node_security_group_use_name_prefix = true
  subnet_ids = var.subnet_ids
}

# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "fubara-rds-subnet-group"
#   subnet_ids = var.subnet_ids
#   description = "RDS subnet group for multi-AZ support"
# }

# resource "aws_security_group" "rds_sg" {
#   name        = "fubara-rds-security-group"
#   vpc_id      = var.vpc_id
#   description = "Allow EKS cluster to access MySQL RDS"

#   ingress {
#     from_port   = 3306
#     to_port     = 3306
#     protocol    = "tcp"
#     security_groups = [module.eks.node_security_group_id] # Restrict access to only EKS VPC
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_db_instance" "mysql" {
#   identifier             = "fubara-mysql-db"
#   engine                 = "mysql"
#   engine_version         = "8.0"
#   instance_class         = "db.t3.micro"
#   allocated_storage      = 20
#   storage_type           = "gp2"
#   storage_encrypted      = true

#   db_name                = var.db_name
#   username               = var.db_username
#   password               = var.db_password

#   publicly_accessible    = true 
#   multi_az               = true

#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]

#   skip_final_snapshot    = true
# }

# resource "null_resource" "init_db" {
#   depends_on = [aws_db_instance.mysql]

#   provisioner "local-exec" {
#     command = <<EOT
#       ENDPOINT="${aws_db_instance.mysql.endpoint}"
#       HOST=$(echo $ENDPOINT | cut -d: -f1)
#       PORT=$(echo $ENDPOINT | cut -d: -f2)
#       mysql -h $HOST -P $PORT -u ${var.db_username} -p${var.db_password} -e "CREATE DATABASE IF NOT EXISTS dream_vacation; USE dream_vacation;"
#     EOT
#   }
# }
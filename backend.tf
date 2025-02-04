terraform {
  backend "s3" {
    bucket         = "terraform-fubara-tfstate-bucket"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "fubara-eks-tfstate-table"
    encrypt        = true
  }
}

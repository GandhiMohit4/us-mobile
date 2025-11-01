variable "access_key" {}
variable "secret_key" {}

variable "aws_region" {
    description = "The AWS region to deploy resources in."
    type        = string
    default     = "us-east-1"  
}

variable "cluster_name" {
    description = "The name for the EKS cluster."
    type        = string
    default     = "us-mobile-interview-cluster"
}

variable "app_name" {
    description = "The name of our sample application."
    type        = string
    default     = "hello-world-app"
}


variable "aws_region" {
  description = "The AWS region to deploy into"
  default     = "ap-south-1" 
}

variable "instance_type" {
  description = "Free tier eligible EC2 instance type"
  default     = "t2.micro"
}

variable "project_name" {
  description = "Name tag for the resources"
  default     = "Weather-CICD-Server"
}

variable "public_key_material" {
  description = "The actual public key string for SSH access"
  type        = string
}
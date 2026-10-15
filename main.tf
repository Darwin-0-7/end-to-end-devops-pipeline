#Remote Backend 
terraform {
  backend "s3" {
    bucket = "darwin-devops-terraform-state" # Nee create panna bucket name
    key    = "jenkins-pipeline/terraform.tfstate"
    region = "ap-south-1"
  }
}
# 1. Dynamically fetch the latest Ubuntu 22.04 Free Tier AMI for the selected region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key_material
}
# 2. Create the Security Group (Firewall Rules)
resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, HTTP, Flask, and Jenkins traffic"

  ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["49.37.202.83/32", "${aws_instance.jenkins_server.public_ip}/32"] 
}

  ingress {
    description = "Flask Weather App"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins CI/CD"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["49.37.202.83/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Create the EC2 Instance
resource "aws_instance" "devops_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  key_name               = aws_key_pair.deployer.key_name 
  user_data              = file("${path.module}/install_tools.sh")

  tags = {
    Name = var.project_name
  }
}
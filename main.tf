# Generate SSH Key Pair
resource "tls_private_key" "strapi_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "strapi_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.strapi_key.public_key_openssh

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.strapi_key.private_key_pem
  filename        = "${path.module}/strapi-key.pem"
  file_permission = "0400"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "strapi_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for Strapi CMS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "strapi" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.strapi_key.key_name
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]

  user_data = file("${path.module}/install.sh")

  root_block_device {
    volume_size = 8  # Free Tier: up to 30 GB
    volume_type = "gp2"
  }

  tags = {
    Name = "${var.project_name}-instance"
  }
}

# Elastic IP
resource "aws_eip" "strapi_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# Associate Elastic IP with Instance
resource "aws_eip_association" "strapi_eip_assoc" {
  instance_id   = aws_instance.strapi.id
  allocation_id = aws_eip.strapi_eip.id
}

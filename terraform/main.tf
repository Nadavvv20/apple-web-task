provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http_traffic"
  description = "Allow inbound HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh_traffic"
  description = "Allow inbound SSH traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Generate a secure private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload the public key to AWS
resource "aws_key_pair" "web_key" {
  key_name   = "apple_web_key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${path.module}/apple_web_key.pem"
  file_permission = "0400"
}

resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain   = "vpc"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c614dee691cbbf37" # Ubuntu 24.04 LTS
  instance_type = "t3.micro"
  key_name      = aws_key_pair.web_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

              # Install Docker
              curl -fsSL https://get.docker.com -o get-docker.sh
              sh get-docker.sh

              # Ensure docker-compose command works (Symlink V2 to V1 style)
              ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

              # Add user to docker group
              usermod -aG docker ubuntu
              newgrp docker
              EOF

  tags = {
    Name = "web_server"
  }
}

output "public_ip" {
  value = aws_eip.web_eip.public_ip
}



terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NimbusCart"
      Environment = "Assignment"
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# ---------------------------------------------------------
# WEB VPC
# ---------------------------------------------------------

resource "aws_vpc" "web" {
  cidr_block           = var.web_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-web-vpc"
  }
}

resource "aws_internet_gateway" "web" {
  vpc_id = aws_vpc.web.id

  tags = {
    Name = "${var.project_name}-web-igw"
  }
}

resource "aws_subnet" "web_public" {
  vpc_id                  = aws_vpc.web.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-web-public"
  }
}

resource "aws_route_table" "web_public" {
  vpc_id = aws_vpc.web.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web.id
  }

  tags = {
    Name = "${var.project_name}-web-public-rt"
  }
}

resource "aws_route_table_association" "web_public" {
  subnet_id      = aws_subnet.web_public.id
  route_table_id = aws_route_table.web_public.id
}

# ---------------------------------------------------------
# APP VPC
# ---------------------------------------------------------

resource "aws_vpc" "app" {
  cidr_block           = var.app_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-app-vpc"
  }
}

resource "aws_subnet" "app_private_a" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-app-private-a"
  }
}

resource "aws_subnet" "app_private_b" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-app-private-b"
  }
}
#----------------------------------------------

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id

  tags = {
    Name = "${var.project_name}-app-igw"
  }
}

resource "aws_subnet" "app_public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.1.100.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-app-public"
  }
}

resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }

  tags = {
    Name = "${var.project_name}-app-public-rt"
  }
}

resource "aws_route_table_association" "app_public" {
  subnet_id      = aws_subnet.app_public.id
  route_table_id = aws_route_table.app_public.id
}

# ---------------------------------------------------------
# APP NAT GATEWAY
# ---------------------------------------------------------

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "app" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.app_public.id

  depends_on = [
    aws_internet_gateway.app
  ]

  tags = {
    Name = "${var.project_name}-nat"
  }
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.app.id

  route {
  cidr_block     = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.app.id
}

  tags = {
    Name = "${var.project_name}-app-private-rt"
  }
}

resource "aws_route_table_association" "app_private_a" {
  subnet_id      = aws_subnet.app_private_a.id
  route_table_id = aws_route_table.app_private.id
}

resource "aws_route_table_association" "app_private_b" {
  subnet_id      = aws_subnet.app_private_b.id
  route_table_id = aws_route_table.app_private.id
}

# ---------------------------------------------------------
# DATA VPC
# ---------------------------------------------------------

resource "aws_vpc" "data" {
  cidr_block           = var.data_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-data-vpc"
  }
}

resource "aws_subnet" "data_private_a" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-data-private-a"
  }
}

resource "aws_subnet" "data_private_b" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-data-private-b"
  }
}

resource "aws_route_table" "data_private" {
  vpc_id = aws_vpc.data.id

  tags = {
    Name = "${var.project_name}-data-private-rt"
  }
}

resource "aws_route_table_association" "data_private_a" {
  subnet_id      = aws_subnet.data_private_a.id
  route_table_id = aws_route_table.data_private.id
}

resource "aws_route_table_association" "data_private_b" {
  subnet_id      = aws_subnet.data_private_b.id
  route_table_id = aws_route_table.data_private.id
}

# ---------------------------------------------------------
# VPC PEERING
# ---------------------------------------------------------

resource "aws_vpc_peering_connection" "web_app" {
  vpc_id      = aws_vpc.web.id
  peer_vpc_id = aws_vpc.app.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-web-app-peering"
  }
}

resource "aws_vpc_peering_connection" "app_data" {
  vpc_id      = aws_vpc.app.id
  peer_vpc_id = aws_vpc.data.id
  auto_accept = true

  tags = {
    Name = "${var.project_name}-app-data-peering"
  }
}

# ---------------------------------------------------------
# WEB <-> APP ROUTES
# ---------------------------------------------------------

resource "aws_route" "web_to_app" {
  route_table_id            = aws_route_table.web_public.id
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.web_app.id
}

resource "aws_route" "app_to_web" {
  route_table_id            = aws_route_table.app_private.id
  destination_cidr_block    = var.web_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.web_app.id
}

# ---------------------------------------------------------
# APP <-> DATA ROUTES
# ---------------------------------------------------------

resource "aws_route" "app_to_data" {
  route_table_id            = aws_route_table.app_private.id
  destination_cidr_block    = var.data_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_data.id
}

resource "aws_route" "data_to_app" {
  route_table_id            = aws_route_table.data_private.id
  destination_cidr_block    = var.app_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.app_data.id
}
# ---------------------------------------------------------
# SECURITY GROUPS
# ---------------------------------------------------------

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for NimbusCart Web tier"
  vpc_id      = aws_vpc.web.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}


resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for NimbusCart App tier"
  vpc_id      = aws_vpc.app.id

  ingress {
    description = "HTTP from Web VPC"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = [var.web_vpc_cidr]
  }

  ingress {
    description = "SSH from Web VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.web_vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}


resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for NimbusCart database"
  vpc_id      = aws_vpc.data.id

  ingress {
    description = "PostgreSQL from App VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.app_vpc_cidr]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

# ---------------------------------------------------------
# ---------------------------------------------------------
# UBUNTU AMI
# ---------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ---------------------------------------------------------
# SSH KEY PAIR
# ---------------------------------------------------------

data "aws_key_pair" "nimbuscart" {
  key_name = var.key_name
}

# ---------------------------------------------------------
# WEB EC2
# ---------------------------------------------------------

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.web_public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = data.aws_key_pair.nimbuscart.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y nginx

    systemctl enable nginx
    systemctl start nginx

    cat > /var/www/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html>
    <head>
      <title>NimbusCart</title>
    </head>
    <body>
      <h1>NimbusCart</h1>
      <p>Web tier is running.</p>
    </body>
    </html>
    HTML
  EOF

  tags = {
    Name = "${var.project_name}-web"
  }
}


# ---------------------------------------------------------
# APP EC2
# ---------------------------------------------------------

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.app_private_a.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = data.aws_key_pair.nimbuscart.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.app_ec2.name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y docker.io awscli

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu

    mkdir -p /opt/nimbuscart
    chmod 755 /opt/nimbuscart
  EOF

  tags = {
    Name = "${var.project_name}-app"
  }
}


# ---------------------------------------------------------
# RDS SUBNET GROUP
# ---------------------------------------------------------

resource "aws_db_subnet_group" "nimbuscart" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    aws_subnet.data_private_a.id,
    aws_subnet.data_private_b.id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}


# ---------------------------------------------------------
# RDS POSTGRESQL
# ---------------------------------------------------------

resource "aws_db_instance" "nimbuscart" {
  identifier = "${var.project_name}-db"

  engine         = "postgres"
  engine_version = "16"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "nimbuscart"
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.nimbuscart.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 0

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "${var.project_name}-database"
  }
}

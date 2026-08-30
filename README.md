# Nimbuscart
Three-tier AWS application using Terraform, Docker, and Nginx.
## Architecture

- **Web Tier:** Nginx on EC2
- **App Tier:** Dockerized REST API
- **Data Tier:** PostgreSQL database
- **Infrastructure:** Terraform
- **Networking:** VPCs, subnets, NAT Gateway, and VPC Peering

## Features

- View products
- Add new products
- REST API with PostgreSQL
- Nginx reverse proxy
- Automated AWS deployment using Terraform and Bash

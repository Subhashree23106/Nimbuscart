output "web_public_ip" {
  description = "Public IP of Web EC2"
  value       = aws_instance.web.public_ip
}

output "app_private_ip" {
  description = "Private IP of App EC2"
  value       = aws_instance.app.private_ip
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.nimbuscart.address
}

output "peering_connection_id" {
  description = "App to Data VPC peering connection"
  value       = aws_vpc_peering_connection.app_data.id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = aws_eip.nat.public_ip
}

output "frontend_url" {
  description = "NimbusCart frontend URL"
  value       = "http://${aws_instance.web.public_ip}"
}

output "web_app_peering_connection_id" {
  description = "Web to App VPC peering connection"
  value       = aws_vpc_peering_connection.web_app.id
}

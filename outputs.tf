output "strapi_url" {
  description = "Strapi CMS URL (Elastic IP - stays the same)"
  value       = "http://${aws_eip.strapi_eip.public_ip}:1337"
}

output "strapi_admin_url" {
  description = "Strapi Admin Panel URL (Elastic IP - stays the same)"
  value       = "http://${aws_eip.strapi_eip.public_ip}:1337/admin"
}

output "elastic_ip" {
  description = "Elastic IP address (permanent)"
  value       = aws_eip.strapi_eip.public_ip
}

output "instance_public_ip" {
  description = "EC2 instance public IP (via Elastic IP)"
  value       = aws_eip.strapi_eip.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i strapi-key.pem ubuntu@${aws_eip.strapi_eip.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.strapi.id
}

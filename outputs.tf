output "server_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.devops_server.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins"
  value       = "http://${aws_instance.devops_server.public_ip}:8080"
}

output "weather_app_url" {
  description = "URL to access your running Python App"
  value       = "http://${aws_instance.devops_server.public_ip}:5000"
}
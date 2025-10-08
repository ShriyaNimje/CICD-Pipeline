output "ec2_public_ip" {
  value = aws_instance.python_app_ec2.public_ip
  description = "Public IP of the Python App EC2 instance"
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "python_app_ec2" {
  ami           = "ami-0c02fb55956c7d316"  # Update for your region
  instance_type = var.instance_type
  key_name      = var.key_name

  # Use existing Jenkins security group
  vpc_security_group_ids = [var.jenkins_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y docker.io git
              docker run -d -p 5000:5000 python-app:latest
              EOF

  tags = {
    Name = "PythonAppServer"
  }
}

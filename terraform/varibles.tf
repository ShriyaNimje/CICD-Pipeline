variable "aws_region" {
  description = "AWS region"
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for EC2"
  default     = "LBkey"
}

variable "jenkins_sg_id" {
  description = "Existing Jenkins security group ID"
  default     = ""
}

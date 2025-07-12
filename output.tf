output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.apterp_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.apterp_ec2.public_ip
}

output "ec2_instance_id" {
  description = "Instance ID of the EC2"
  value       = aws_instance.apterp_ec2.id
}


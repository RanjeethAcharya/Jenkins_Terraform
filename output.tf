output "instance_IP" {
  value = aws_instance.ubuntu.public_ip
}

output "instance_id" {
  value = aws_instance.ubuntu.id
}

output "vpc_id" {
  value = aws_vpc.ranjeeth-vpc.id
}



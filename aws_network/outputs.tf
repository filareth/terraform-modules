output "vpc_id" {
  value = aws_vpc.dev.id
}

output "vpc_cidr" {
  value = aws_vpc.dev.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}


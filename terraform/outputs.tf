output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_public_dns" {
  value = aws_instance.master.public_dns
}

output "master_ssh_command" {
  value = "ssh -i ~/.ssh/${var.key_name}.pem ${var.ssh_user}@${aws_instance.master.public_ip}"
}
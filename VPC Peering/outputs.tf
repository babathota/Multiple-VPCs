output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "private_ips" {
  value = { for k, v in aws_instance.private_test : k => v.private_ip }
}
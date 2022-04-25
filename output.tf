output "instance_ip_addr" {
  value = aws_instance.test_server.public_ip
}
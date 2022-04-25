# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "my-vpc"
#   cidr = "10.0.0.0/16"

#   azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = true

#   tags = {
#     Terraform = "true"
#     Environment = "dev"
#   }
# }

resource "aws_security_group" "sg_test_server" {
  name        = "sg_test_server"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress = [{
    description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
  },
  {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["88.151.144.193/32"]
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
  }]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("/Users/ankanghosh/.ssh/terraform.pub")}"
}

resource "aws_instance" "test_server" {
  ami           = "ami-0dcc0ebde7b2e00db"
  instance_type = var.instance_type
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.sg_test_server.id]
  user_data = data.template_file.user_data.rendered

  provisioner "remote-exec" {
    inline = [
      "echo ${self.private_ip} >> private_ips.txt"
    ]

    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_ip
      private_key = "${file("/Users/ankanghosh/.ssh/terraform")}"
    }
  }

  tags = {
    Name = "TestServer-${local.project_name}"
  }
}

resource "null_resource" "status" {
  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.test_server.id}"
  }

  depends_on = [
    aws_instance.test_server
  ]

}

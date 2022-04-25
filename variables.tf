variable "instance_type" {
  type = string
  validation {
    condition = length(var.instance_type) != 0
    error_message = "Instance Type null found."
  }
}

locals {
  project_name = "Ankan's"
}

data "aws_vpc" "main"{
    id = "vpc-ec667a87"
}

data "template_file" "user_data"{
    template = file("./userdata.yaml")
}
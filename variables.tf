data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]
    
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/*-20.04-amd64-server-*"]
    }

    filter {
        name = "root-device-type"
        values = ["ebs"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

variable "AZ-ec2_name" {
  description = "availability zones-and machines in them"
  type = map
  default = {
    "webserver-1" = "eu-central-1a"
    "websever-2" = "eu-central-1b"
    "bastion" =  "eu-central-1c"
    "Ansible-node" = "eu-central-1a"
    "Terraform-node" = "eu-central-1b" 
  }
}
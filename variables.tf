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


variable "ec2" {
  type = list(object({
  instance_type = string
  service = string #web ,Ansible, Terraform
  zone = string  # 1a, 1b, 1c
  }))
} 

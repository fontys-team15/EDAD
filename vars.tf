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

# VPCs
variable "vpc" {
  type = object({
    web = string
    rds = string
    ao = string
  })

  default = {
    web = "10.0.0.0/16"
    rds = "172.16.0.0/24"
    ao = "192.168.0.0/24"
  }
}

# subnets
variable "subnets" {
  type = list(object({
    vpc = string  # e.g., "web", "ao", "rds"
    service = string  # e.g., "ws", "bh", "tf", "ansbl"
    cidr_block = string  
    zone = string  # e.g., "1a", "1b", "1c"
    public = bool    # e.g., true or false
  }))
}

# EC2
variable "ec2" {
  type = list(object({
    instance_type = string
    vpc = string  # e.g., "web", "ao", "rds"
    service = string  # e.g., "ws", "bh", "tf", "ansbl"
    zone = string  # e.g., "1a", "1b", "1c"
  }))
}


variable "eip" {
  type = list(string)
  default = [ "web_ngw_eip", "ao_ngw_eip" ]
}

# gateways
variable "igw" {
  type = list(object({
    vpc = string
  }))
}

variable "ngw" {
  type = list(object({
    vpc = string
    service = string
    zone = string
    public = bool
  }))
}

variable "pcx" {
  type = list(object({
    peer_vpc = string
    vpc = string
  }))
}

# rt
variable "rt" {
  type = list(object({
    vpc = string
    service = string
    rule = list(object({
      vpc_cidr = bool
      cidr_block = string # e.g. web, ao, rds, 0.0.0.0/0
      gateway_type = string # e.g. ngw, igw, pcx
      gateway_id = string
    }))
  }))
}

# rt associations
# main
variable "rt_main" {
  type = list(object({
    vpc = string
    service = string
  }))
}
# explicit associations
variable "rt_ex" {
  type = list(object({
    vpc = string
    service = string
    zone = string
    public = bool
  }))
}

variable "sg" {
  type = list(object({ 
    vpc = string
    service = string
    ingress = list(object({
      vpcl = string
      servicel = string
      public = bool
      zone = string
      vpc_cidr = bool
      cidr = string
      from_port = number
      to_port = number
      protocol = string
    }))
    egress = list(object({
      vpcl = string
      servicel = string
      vpc_cidr = bool
      public = bool
      zone = string
      cidr = string
      from_port = number
      to_port = number
      protocol = string
    }))  
  }))
}
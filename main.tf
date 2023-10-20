terraform {
  cloud {
    organization = "Fontys-learning"
    workspaces {
      name = "ASSmgt"
    }
  }
  required_providers {
     aws = {
      source = "hashicorp/aws"
      version = "5.19.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}


locals {
  vpc_mapping = { for k, v in aws_vpc.vpc : k => v }
  subnet_mapping = { for k, v in aws_subnet.subnets : k => v }
  subnet_cidr = { for k, v in aws_subnet.subnets : k => v.cidr_block }
  gateway_mappings = {
    eip  = { for k, v in aws_eip.eip : k => v.id },
    igw  = { for k, v in aws_internet_gateway.igw : k => v.id },
    pcx  = { for k, v in aws_vpc_peering_connection.pcx : k => v.id }    
  }
  ngw  = { for k, v in aws_nat_gateway.ngw : k => v.id }
  sg_mapping = { for k, v in aws_security_group.sg : k => v }
  region = "eu-central"
}


# ------- #
# VPC     #
# ------- #

resource "aws_vpc" "vpc" {
  for_each = var.vpc
  cidr_block = each.value

  tags = {
    Name = each.key
  }
}


# ------- #
# Subnets #
# ------- #

resource "aws_subnet" "subnets" {
  for_each = { for s in var.subnets : "${s.vpc}_${s.service}-${s.zone}${s.public ? "_pub" : ""}_subnet" => s }

  vpc_id = local.vpc_mapping[each.value.vpc].id
  cidr_block = each.value.cidr_block
  availability_zone = "${local.region}-${each.value.zone}"
  
  tags = {
    Name = each.key
  }
}


# --- #
# EIP #
# --- #

resource "aws_eip" "eip" {
  for_each = toset(var.eip)
  domain   = "vpc"
}


# -------- #
# Gateways #
# -------- #

resource "aws_internet_gateway" "igw" {
  for_each = { for igw in var.igw : "${igw.vpc}_igw" => igw }
  vpc_id = local.vpc_mapping[each.value.vpc].id
  
  tags = {
    Name = each.key
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each = { for ngw in var.ngw : "${ngw.vpc}_ngw" => ngw }

  allocation_id = lookup(local.gateway_mappings["eip"], "${each.value.vpc}_ngw_eip")
  subnet_id     = local.subnet_mapping["${each.value.vpc}_${each.value.service}-${each.value.zone}${each.value.public ? "_pub" : ""}_subnet"].id

  tags = {
    Name = each.key
  }
  # depends_on = [ aws_internet_gateway.igw, aws_eip.eip ]
}

resource "aws_vpc_peering_connection" "pcx" {
  for_each = { for pcx in var.pcx : "${pcx.peer_vpc}_${pcx.vpc}_pcx" => pcx }
  peer_vpc_id = local.vpc_mapping[each.value.peer_vpc].id
  vpc_id = local.vpc_mapping[each.value.vpc].id
  
  tags = {
    Name = each.key
  }
}


# -------------- #
# Rouging tables #
# -------------- #

resource "aws_route_table" "rt" {
  for_each = { for t in var.rt : "${t.vpc}_${t.service}_rt" => t }
  vpc_id = local.vpc_mapping[each.value.vpc].id

  dynamic "route" {
    for_each = each.value.rule
    content {
      cidr_block = route.value.vpc_cidr ? local.vpc_mapping[route.value.cidr_block].cidr_block : route.value.cidr_block # because vpc_mapping contains multiple attributes
      gateway_id = route.value.gateway_type != "ngw" ? lookup(local.gateway_mappings[route.value.gateway_type], route.value.gateway_id, "local") : lookup(local.ngw, route.value.gateway_id, "local")

    }
  }
}


# --------------------------- #
# Routing tables associations #
# --------------------------- #

resource "aws_main_route_table_association" "rt_main" {
  for_each = { for mrt in var.rt_main : "${mrt.vpc}_main_rt" => mrt }
  vpc_id = local.vpc_mapping[each.value.vpc].id
  route_table_id = aws_route_table.rt["${each.value.vpc}_${each.value.service}_rt"].id
}

resource "aws_route_table_association" "rt_ex" {
  for_each = { for ert in var.rt_ex : "${ert.vpc}_${ert.service}${ert.zone}_ex_rt" => ert }
  subnet_id = local.subnet_mapping["${each.value.vpc}_${each.value.service}-${each.value.zone}${each.value.public ? "_pub" : ""}_subnet"].id
  route_table_id = aws_route_table.rt["${each.value.vpc}_${each.value.service}_rt"].id
}


resource "aws_security_group" "sg" {
  for_each = { for sg in var.sg : "${sg.vpc}_${sg.service}_sg" => sg}
  vpc_id = local.vpc_mapping[each.value.vpc].id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = [ingress.value.vpc_cidr ? local.vpc_mapping[ingress.value.vpcl].cidr_block : lookup(local.subnet_cidr,"${ingress.value.vpcl}_${ingress.value.servicel}-${ingress.value.zone}${ingress.value.public ? "_pub" : ""}_subnet",ingress.value.cidr)]
    }
  }
  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port = egress.value.from_port
      to_port = egress.value.to_port
      protocol = egress.value.protocol
      cidr_blocks = [egress.value.vpc_cidr ? local.vpc_mapping[egress.value.vpcl].cidr_block : lookup(local.subnet_cidr,"${egress.value.vpcl}_${egress.value.servicel}-${egress.value.zone}${egress.value.public ? "_pub" : ""}_subnet",egress.value.cidr)]
    }
  }
}


# --- #
# SSH #
# --- #

# resource "aws_key_pair" "admin_key" {
#   key_name   = "admin_key"
#   public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOp3Jjx+TyaSEssPN8A7XE5Y75HGDgYQDpUfD5afMaJ0 crhackaddict@msigmachine"
# }


# --- #
# EC2 #
# --- #

//add VPC association
# resource "aws_instance" "ec2" {
#   for_each = {for ec in var.ec2 : "${ec.service}-${ec.zone}_ec2" => ec}

#   ami = data.aws_ami.ubuntu.id
#   instance_type = each.value.instance_type
#   availability_zone = "${local.region}-${each.value.zone}"

#   vpc_security_group_ids = []
#   key_name = aws_key_pair.admin_key.key_name

#   tags = {
#     Name = each.key
#   }
# }

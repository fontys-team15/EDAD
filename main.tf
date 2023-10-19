terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.20.1"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}


locals {
  vpc_mapping = { for k, v in aws_vpc.vpc : k => v }
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

resource "aws_eip" "ao_ngw_eip" {
  domain   = "vpc"
}

resource "aws_eip" "web_ngw_eip" {
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

resource "aws_internet_gateway" "ngw" {
  for_each = { for ngw in var.ngw : "${ngw.vpc}_ngw" => ngw }
  vpc_id = local.vpc_mapping[each.value.vpc].id
  
  tags = {
    Name = each.key
  }
}

resource "aws_internet_gateway" "pcx" {
  for_each = { for pcx in var.pcx : "${pcx.peer_vpc}_${pcx.vpc}_pcx" => pcx }
  vpc_id = local.vpc_mapping[each.value.vpc].id
  
  tags = {
    Name = each.key
  }
}


# --- #
# SSH #
# --- #
resource "aws_key_pair" "admin_key" {
  key_name   = "admin_key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOp3Jjx+TyaSEssPN8A7XE5Y75HGDgYQDpUfD5afMaJ0 crhackaddict@msigmachine"
}


# --- #
# EC2 #
# --- #

//add VPC association
resource "aws_instance" "ec2" {
  for_each = {for ec in var.ec2 : "${ec.service}-${ec.zone}_ec2" => ec}

  ami = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  availability_zone = "${local.region}-${each.value.zone}"

  vpc_security_group_ids = []
  key_name = aws_key_pair.admin_key.key_name

  tags = {
    Name = each.key
  }
}

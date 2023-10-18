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
  vpc_mapping = { for k, v in aws_vpc.vpc : k => v.id }
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

resource "aws_subnet" "subnet" {
  for_each = { for s in var.subnets : "${s.service}${s.zone}_${s.public ? "pub" : ""}_subnet" => s }

  vpc_id            = lookup(local.vpc_mapping, each.value.service)
  cidr_block        = each.value.cidr_block
  availability_zone = "${local.region}-${each.value.zone}"
  tags = {
    Name = each.key
  }
}

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
  region = "eu-central"
}


# ------- #
# VPC     #
# ------- #
resource "aws_vpc" "web_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "web_vpc"
  }
}

resource "aws_vpc" "rds_vpc" {
  cidr_block = "172.16.0.0/24"

  tags = {
    Name = "rds_vpc"
  }
}

resource "aws_vpc" "ao_vpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    Name = "ao_vpc"
  }
}

# ------- #
# Subnets #
# ------- #

# web subnets
resource "aws_subnet" "web1a_subnet" {
    vpc_id = aws_vpc.web_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "eu-central-1a"
    tags = {
      Name = "web1a_subnet"
    }
}

resource "aws_subnet" "web1b_subnet" {
    vpc_id = aws_vpc.web_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "web1b_subnet"
    }
}

resource "aws_subnet" "web1a_pub_subnet" {
    vpc_id = aws_vpc.web_vpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "eu-central-1a"
    tags = {
      Name = "web1a_pub_subnet"
    }
}

resource "aws_subnet" "web1b_pub_subnet" {
    vpc_id = aws_vpc.web_vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "web1b_pub_subnet"
    }
}

resource "aws_subnet" "web1c_subnet" {
    vpc_id = aws_vpc.web_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-central-1c"
    tags = {
      Name = "web1c_subnet"
    }
}

# rds subnets
resource "aws_subnet" "rds1a_subnet" {
    vpc_id = aws_vpc.rds_vpc.id
    cidr_block = "172.16.0.0/25"
    availability_zone = "eu-central-1a"
    tags = {
      Name = "rds1a_subnet"
    }
}

resource "aws_subnet" "rds1b_subnet" {
    vpc_id = aws_vpc.rds_vpc.id
    cidr_block = "172.16.0.128/25"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "rds1b_subnet"
    }
}

# ao subnets
resource "aws_subnet" "ao1a_subnet" {
    vpc_id = aws_vpc.ao_vpc.id
    cidr_block = "192.168.0.0/28"
    availability_zone = "eu-central-1a"
    tags = {
      Name = "ao1a_subnet"
    }
}

resource "aws_subnet" "ao1b_subnet" {
    vpc_id = aws_vpc.ao_vpc.id
    cidr_block = "192.168.0.16/28"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "ao1b_subnet"
    }
}

resource "aws_subnet" "ao1c_subnet" {
    vpc_id = aws_vpc.ao_vpc.id
    cidr_block = "192.168.0.32/28"
    availability_zone = "eu-central-1c"
    tags = {
      Name = "ao1c_subnet"
    }
}

# -------------- #
# Routing tables #
# -------------- #

# web routing
resource "aws_route_table" "web_rt" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = aws_vpc.web_vpc.cidr_block
    gateway_id = "local"
  }
  
  route {
    cidr_block = aws_vpc.rds_vpc.cidr_block
    gateway_id = aws_vpc_peering_connection.web_rds_pcx.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.web_ngw.id
  }
}

resource "aws_route_table" "web_pub_rt" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = aws_vpc.web_vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}

resource "aws_route_table" "web1c_rt" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = aws_vpc.web_vpc.cidr_block
    gateway_id = "local"
  }
  
  route {
    cidr_block = aws_vpc.rds_vpc.cidr_block
    gateway_id = aws_vpc_peering_connection.web_rds_pcx.id
  }

  route {
    cidr_block = aws_vpc.ao_vpc.cidr_block
    gateway_id = aws_vpc_peering_connection.web_ao_pcx.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_igw.id
  }
}

# rds routing
resource "aws_route_table" "rds_rt" {
  vpc_id = aws_vpc.rds_vpc.id

  route {
    cidr_block = aws_vpc.rds_vpc.cidr_block
    gateway_id = "local"
  }
  
  route {
    cidr_block = aws_vpc.web_vpc.cidr_block
    gateway_id = aws_vpc_peering_connection.web_rds_pcx.id
  }
}

# ao routing
resource "aws_route_table" "ao_rt" {
  vpc_id = aws_vpc.ao_vpc.id

  route {
    cidr_block = aws_vpc.ao_vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = aws_vpc.web_vpc.cidr_block
    gateway_id = aws_vpc_peering_connection.web_ao_pcx.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ao_ngw.id
  }
}

resource "aws_route_table" "ao1c_rt" {
  vpc_id = aws_vpc.ao_vpc.id

  route {
    cidr_block = aws_vpc.ao_vpc.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ao_igw.id
  }
}

# --------------------------- #
# Routing tables associations #
# --------------------------- #

resource "aws_main_route_table_association" "web_rt" {
  vpc_id         = aws_vpc.web_vpc.id
  route_table_id = aws_route_table.web_rt.id
}

resource "aws_route_table_association" "web1c_rt" {
  subnet_id      = aws_subnet.web1c_subnet.id
  route_table_id = aws_route_table.web1c_rt.id
}

resource "aws_route_table_association" "web1a_pub_rt" {
  subnet_id      = aws_subnet.web1a_pub_subnet.id
  route_table_id = aws_route_table.web_pub_rt.id
}

resource "aws_route_table_association" "web1b_pub_rt" {
  subnet_id      = aws_subnet.web1b_pub_subnet.id
  route_table_id = aws_route_table.web_pub_rt.id
}

resource "aws_main_route_table_association" "rds_rt" {
  vpc_id         = aws_vpc.rds_vpc.id
  route_table_id = aws_route_table.rds_rt.id
}

resource "aws_main_route_table_association" "ao_rt" {
  vpc_id         = aws_vpc.ao_vpc.id
  route_table_id = aws_route_table.ao_rt.id
}

resource "aws_route_table_association" "ao1c_rt" {
  subnet_id      = aws_subnet.ao1c_subnet.id
  route_table_id = aws_route_table.ao1c_rt.id
}

# --------------- #
# Security groups #
# --------------- #

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.web1c_subnet.cidr_block]
  }

  ingress {
    description      = "Allow HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.web_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}


resource "aws_security_group" "web1c_sg" {
  name        = "web1c_sg"
  description = "Allow SSH from everywhere."
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web1c_sg"
  }
}

resource "aws_security_group" "web_alb_sg" {
  name        = "web_alb_sg"
  description = "Allow HTTP from everywhere."
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description      = "Allow HTTP."
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_alb_sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow DB traffic"
  vpc_id      = aws_vpc.rds_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.web_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}


resource "aws_security_group" "ao_sg" {
  name        = "ao_sg"
  description = "Allow SSH inbound traffic coming from web1c"
  vpc_id      = aws_vpc.ao_vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_subnet.web1c_subnet.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ao_sg"
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

# internet gateways
resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "web_igw"
  }
}

resource "aws_internet_gateway" "ao_igw" {
  vpc_id = aws_vpc.ao_vpc.id

  tags = {
    Name = "ao_igw"
  }
}

# nat gateways
resource "aws_nat_gateway" "web_ngw" {
  allocation_id = aws_eip.web_ngw_eip.id
  subnet_id     = aws_subnet.web1c_subnet.id

  tags = {
    Name = "web_ngw"
  }

  depends_on = [aws_internet_gateway.web_igw]
}


resource "aws_nat_gateway" "ao_ngw" {
  allocation_id = aws_eip.ao_ngw_eip.id
  subnet_id     = aws_subnet.ao1c_subnet.id

  tags = {
    Name = "ao_ngw"
  }

  depends_on = [aws_internet_gateway.ao_igw]
}

# peering
resource "aws_vpc_peering_connection" "web_rds_pcx" {
  peer_vpc_id   = aws_vpc.web_vpc.id
  vpc_id        = aws_vpc.rds_vpc.id

  tags = {
    Name = "web_rds_pcx"
  }
}

resource "aws_vpc_peering_connection" "web_ao_pcx" {
  peer_vpc_id   = aws_vpc.web_vpc.id
  vpc_id        = aws_vpc.ao_vpc.id

  tags = {
    Name = "web_ao_pcx"
  }
}

# --- #
# ALB #
# --- #

resource "aws_lb_target_group" "alb_tg" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id
}

resource "aws_lb_target_group_attachment" "web1a_tg_attch" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web1a_i.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web1b_tg_attch" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.web1b_i.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_alb_sg.id]
  subnets            = [aws_subnet.web1a_pub_subnet.id, aws_subnet.web1b_pub_subnet.id]

  enable_deletion_protection = false
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

# resource "aws_instance" "web1a_i" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   availability_zone = "eu-central-1a"
#   vpc_security_group_ids = [aws_security_group.web_sg.id]
#   key_name = aws_key_pair.admin_key.key_name
#   subnet_id = aws_subnet.web1a_subnet.id

#   tags = {
#     Name = "web1a_i"
#   }
# }

# resource "aws_instance" "web1b_i" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   availability_zone = "eu-central-1b"
#   vpc_security_group_ids = [aws_security_group.web_sg.id]
#   key_name = aws_key_pair.admin_key.key_name
#   subnet_id = aws_subnet.web1b_subnet.id

#   tags = {
#     Name = "web1b_i"
#   }
# }

# resource "aws_instance" "web1c_i" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   availability_zone = "eu-central-1c"
#   vpc_security_group_ids = [aws_security_group.web1c_sg.id]
#   key_name = aws_key_pair.admin_key.key_name
#   subnet_id = aws_subnet.web1c_subnet.id
#   associate_public_ip_address = true

#   tags = {
#     Name = "web1c_i"
#   }
# }

# # ao instances
# resource "aws_instance" "ao1a_i" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   availability_zone = "eu-central-1a"
#   vpc_security_group_ids = [aws_security_group.ao_sg.id]
#   key_name = aws_key_pair.admin_key.key_name
#   subnet_id = aws_subnet.ao1a_subnet.id

#   tags = {
#     Name = "ao1a_i"
#   }
# }

# resource "aws_instance" "ao1b_i" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro"
#   availability_zone = "eu-central-1b"
#   vpc_security_group_ids = [aws_security_group.ao_sg.id]
#   key_name = aws_key_pair.admin_key.key_name
#   subnet_id = aws_subnet.ao1b_subnet.id

#   tags = {
#     Name = "ao1b_i"
#   }
# }

//add VPC stuff

resource "aws_instance" "dynamic_ec2" {
  for_each = {for ec in var.ec2 : "${ec.service}-${ec.zone}_ec2" => ec}
  ami = data.aws_ami.ubuntu.id
  instance_type = each.value.instance_type
  availability_zone = "${local.region}-${each.value.zone}"

  tags = {
    Name = each.key
  }
}

# --- #
# RDS #
# --- #


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.rds1a_subnet.id, aws_subnet.rds1b_subnet.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 20
  db_name              = "mydb"
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "qwert1234"
  skip_final_snapshot  = true

  storage_type = "gp2"
  multi_az = true
  delete_automated_backups = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.default.name

  tags = {
    Name = "rds"
  }
}

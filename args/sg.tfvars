sg = [
    {
        vpc = "web"
        service = "ws"
        ingress = [
            {
                servicel = "bh"
                vpcl = "web"
                public = true
                zone = "1c"
                vpc_cidr = false
                from_port = 22
                to_port = 22
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            },
            {
                servicel = ""
                vpcl = "web"
                public = false
                zone = ""
                vpc_cidr = true
                from_port = 80
                to_port = 80
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            }
        ]
        egress = [
            {
                servicel = ""
                vpcl = "web"
                from_port = 0 
                to_port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
                public = false
                zone = ""
                vpc_cidr = false
            }
        ]
    },
    {
        vpc = "web"
        service = "bh"
        ingress = [
            {
                servicel = ""
                vpcl = "web"
                public = false
                zone = ""
                vpc_cidr = false
                from_port = 22
                to_port = 22
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            }
        ]
        egress = [
            {
                servicel = ""
                vpcl = "web"
                from_port = 0 
                to_port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
                public = false
                zone = ""
                vpc_cidr = false
            }
        ]
    },
    {
        vpc = "web"
        service = "alb"
        ingress = [
            {
                servicel = ""
                vpcl = "web"
                public = false
                zone = ""
                vpc_cidr = false
                from_port = 80
                to_port = 80
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            }
        ]
        egress = [
            {
                servicel = ""
                vpcl = "web"
                from_port = 0 
                to_port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
                public = false
                zone = ""
                vpc_cidr = false
            }
        ]
    },
    {
        vpc = "rds"
        service = "rds"
        ingress = [
            {
                servicel = ""
                vpcl = "web"
                public = false
                zone = ""
                vpc_cidr = true
                from_port = 3306
                to_port = 3306
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            },
        ]
        egress = [
            {
                servicel = ""
                vpcl = "rds"
                from_port = 0 
                to_port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
                public = false
                zone = ""
                vpc_cidr = false
            }
        ]
    },
     {
        vpc = "ao"
        service = "ao"
        ingress = [
            {
                servicel = "bh"
                vpcl = "web"
                public = true
                zone = "1c"
                vpc_cidr = false
                from_port = 22
                to_port = 22
                protocol = "tcp" 
                cidr = "0.0.0.0/0"
            }
        ]
        egress = [
            {
                servicel = ""
                vpcl = "ao"
                from_port = 0 
                to_port = 0
                protocol = "-1"
                cidr = "0.0.0.0/0"
                public = false
                zone = ""
                vpc_cidr = false
            }
        ]
    }
]
subnets = [ 
    {
        vpc = "web"
        service = "ws"
        cidr_block = "10.0.0.0/24"
        zone = "1a"
        public = false
    },
    {
        vpc = "web"
        service = "ws"
        cidr_block = "10.0.1.0/24"
        zone = "1b"
        public = false
    },
    {
        vpc = "web"
        service = "alb"
        cidr_block = "10.0.4.0/24"
        zone = "1a"
        public = true
    },
    {
        vpc = "web"
        service = "alb"
        cidr_block = "10.0.3.0/24"
        zone = "1b"
        public = true
    },
    {
        vpc = "web"
        service = "bh"
        cidr_block = "10.0.2.0/24"
        zone = "1c"
        public = true
    }, #rds
    {
        vpc = "rds"
        service = "db"
        cidr_block = "172.16.0.0/25"
        zone = "1a"
        public = false
    },
    {
        vpc = "rds"
        service = "db"
        cidr_block = "172.16.0.128/25"
        zone = "1b"
        public = false
    }
]

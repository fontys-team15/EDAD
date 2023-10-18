subnets = [ 
    {
        service = "web"
        cidr_block = "10.0.0.0/24"
        zone = "1a"
        public = false
    },
    {
        service = "web"
        cidr_block = "10.0.1.0/24"
        zone = "1b"
        public = false
    },
    {
        service = "web"
        cidr_block = "10.0.4.0/24"
        zone = "1a"
        public = true
    },
    {
        service = "web"
        cidr_block = "10.0.3.0/24"
        zone = "1b"
        public = true
    },
    {
        service = "web"
        cidr_block = "10.0.2.0/24"
        zone = "1c"
        public = true
    }, #rds
    {
        service = "rds"
        cidr_block = "172.16.0.0/25"
        zone = "1a"
        public = false
    },
    {
        service = "rds"
        cidr_block = "172.16.0.128/25"
        zone = "1b"
        public = false
    }, #ao
    {
        service = "ao"
        cidr_block = "192.168.0.0/28"
        zone = "1a"
        public = false
    },
    {
        service = "ao"
        cidr_block = "192.168.0.16/28"
        zone = "1b"
        public = false
    },
    {
        service = "ao"
        cidr_block = "192.168.0.32/28"
        zone = "1c"
        public = true
    }
]

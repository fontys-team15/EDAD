ec2 = [ 
    # web
    {
        vpc = "web"
        service = "ws"
        zone = "1a"
        instance_type = "t2.micro"
        public_ip = false
        public_subnet = false
    },
    {
        vpc = "web"
        service = "ws"
        zone = "1b"
        instance_type = "t2.micro"
        public_ip = false
        public_subnet = false
    },
    {
        vpc = "web"
        service = "bh"
        zone = "1c"
        instance_type = "t2.micro"
        public_ip = true
        public_subnet = true
    }, #ao
    {
        vpc = "ao"
        service = "ao"
        zone = "1a"
        instance_type = "t2.micro"
        public_ip = false
        public_subnet = false
    },
    {
        vpc = "ao"
        service = "ao"
        zone = "1b"
        instance_type = "t2.micro"
        public_ip = false
        public_subnet = false
    }
]
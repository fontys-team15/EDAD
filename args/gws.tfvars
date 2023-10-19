igw = [
    {
        vpc = "web"
    },
    {
        vpc = "ao"
    }
]

ngw = [
    {
        vpc = "web"
        service = "bh"
        zone = "1c"
        public = true
    },
    {
        vpc = "ao"
        service = "nat"
        zone = "1c"
        public = true
    }
]

pcx = [
    {
        peer_vpc = "web"
        vpc = "rds"
    },
    {
        peer_vpc = "web"
        vpc = "ao"
    }
]
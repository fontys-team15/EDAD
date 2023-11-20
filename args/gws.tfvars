igw = [
    {
        vpc = "web"
    }
]

ngw = [
    {
        vpc = "web"
        service = "bh"
        zone = "1c"
        public = true
    }
]

pcx = [
    {
        peer_vpc = "web"
        vpc = "rds"
    }
]
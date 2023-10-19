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
    },
    {
        vpc = "ao"
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
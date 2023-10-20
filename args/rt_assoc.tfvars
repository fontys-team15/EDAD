rt_main = [ 
    {
        vpc = "web"
        service = "ws"
    },
    {
        vpc = "rds"
        service = "rds"
    },
    {
        vpc = "ao"
        service = "ao"
    }
]

rt_ex = [ 
    {
        vpc = "web"
        service = "bh"
        zone = "1c"
        public = true
    },
    {
        vpc = "web"
        service = "alb"
        zone = "1a"
        public = true
    },
    {
        vpc = "web"
        service = "alb"
        zone = "1b"
        public = true
    },
    {
        vpc = "ao"
        service = "nat"
        zone = "1c"
        public = true
    } 
]

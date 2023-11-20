rt_main = [ 
    {
        vpc = "web"
        service = "ws"
    },
    {
        vpc = "rds"
        service = "rds"
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
    }
]

ec2 = [ 
    # web
    {
        service = "web"
        zone = "1a"
        instance_type = "t2.micro"
    },
    {
        service = "web"
        zone = "1b"
        instance_type = "t2.micro"
    },
    {
        service = "web"
        zone = "1c"
        instance_type = "t2.micro"

    }, 
    # ao
    {
        service = "ao"
        zone = "1a"
        instance_type = "t2.micro"
    },
    {
        service = "ao"
        zone = "1b"
        instance_type = "t2.micro"

    }
]
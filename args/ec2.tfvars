ec2 = [ 
    # web
    {
        vpc = "web"
        service = "web1"
        zone = "1a"
        instance_type = "t2.micro"
    },
    {
        vpc = "web"
        service = "web2"
        zone = "1b"
        instance_type = "t2.micro"
    },
    {
        vpc = "web"
        service = "bastion"
        zone = "1c"
        instance_type = "t2.micro"

    }, 
    # ao
    {
        vpc = "ao"
        service = "terraform"
        zone = "1a"
        instance_type = "t2.micro"
    },
    {
        vpc = "ao"
        service = "ansible"
        zone = "1b"
        instance_type = "t2.micro"

    }
]
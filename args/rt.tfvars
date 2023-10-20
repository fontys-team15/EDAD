rt = [ 
    {
        vpc = "web"
        service = "ws"
        rule = [ {
            vpc_cidr = true
            cidr_block = "web"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = true
            cidr_block = "rds"
            gateway_type = "pcx"
            gateway_id = "web_rds_pcx"
        },
        {
            vpc_cidr = false
            cidr_block = "0.0.0.0/0"
            gateway_type = "ngw"
            gateway_id = "web_ngw"
        } ]
    },
    {
        vpc = "web"
        service = "alb"
        rule = [ {
            vpc_cidr = true
            cidr_block = "web"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = false
            cidr_block = "0.0.0.0/0"
            gateway_type = "igw"
            gateway_id = "web_igw"
        } ]
    },
    {
        vpc = "web"
        service = "bh"
        rule = [ {
            vpc_cidr = true
            cidr_block = "web"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = true
            cidr_block = "rds"
            gateway_type = "pcx"
            gateway_id = "web_rds_pcx"
        },
        {
            vpc_cidr = true
            cidr_block = "ao"
            gateway_type = "pcx"
            gateway_id = "web_ao_pcx"
        },
        {
            vpc_cidr = false
            cidr_block = "0.0.0.0/0"
            gateway_type = "igw"
            gateway_id = "web_igw"
        } ]
    },
    {
        vpc = "rds"
        service = "rds"
        rule = [ {
            vpc_cidr = true
            cidr_block = "rds"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = true
            cidr_block = "web"
            gateway_type = "pcx"
            gateway_id = "web_rds_pcx"
        } ]
    },
    {
        vpc = "ao"
        service = "ao"
        rule = [ {
            vpc_cidr = true
            cidr_block = "ao"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = true
            cidr_block = "web"
            gateway_type = "pcx"
            gateway_id = "web_ao_pcx"
        },
        {
            vpc_cidr = false
            cidr_block = "0.0.0.0/0"
            gateway_type = "ngw"
            gateway_id = "ao_ngw"
        } ]
    },
    {
        vpc = "ao"
        service = "nat"
        rule = [ {
            vpc_cidr = true
            cidr_block = "ao"
            gateway_type = "ngw"
            gateway_id = "local"
        },
        {
            vpc_cidr = false
            cidr_block = "0.0.0.0/0"
            gateway_type = "igw"
            gateway_id = "ao_igw"
        } ]
    }
]
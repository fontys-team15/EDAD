## Resource Naming Pattern

- **VPCs**: `<vpc>_vpc`; e.g. `web_vpc`
- **Subnets**: `<vpc>_<service>-<availability_zone>[_pub]_subnet`; e.g. `web_ws-1a_pub_subnet`
- **Route Tables**: `<vpc>_<service>_rt`; e.g. `web_bh_rt`, `web_ws_rt`
- **Security Groups**: `<vpc>_<service>_sg`; e.g. `web_ws_sg`

**VPCs**: `web`, `ao`, `rds`

**SERVICES**: `ws` (web server), `bh` (bastion host), `tf` (Terraform), `ansbl` (Ansible), `db`, `nat`, `pcx`

## Variable Convention

Prefer `map()` over `list()`.

This is because when using the `for_each` meta-argument Terraform automatically assigns an identifier to each instance based on the keys in the provided "collection". The difference between using maps over lists is that the keys of a map can be way more descriptive unlike the values of a list (Terraform will convert each item in the list to a string and use that as the identifier → not ideal identifier).

## Use Case

Within a `vars.tf` file we have the following variable:

```hcl
variable "subnets" {
  type = list(object({
    vpc         = string  # e.g., "web", "ao", "rds"
    service     = string  # e.g., "ws", "bh", "tf", "ansbl"
    cidr_block  = string  
    zone        = string  # e.g., "1a", "1b", "1c"
    public      = bool    # e.g., true or false
  }))
}
```
In the main.tf file there are the following blocks:

```hcl
...
locals {
  vpc_mapping = { for k, v in aws_vpc.vpc : k => v }
  region = "eu-central-"
}
...

resource "aws_subnet" "dynamic_subnets" {
  for_each = { for s in var.subnets : "${s.vpc}_${s.service}${s.zone}${s.public ? "_pub" : ""}_subnet" => s }

  vpc_id            = local.vpc_mapping[each.value.vpc].id
  cidr_block        = each.value.cidr_block
  availability_zone = "${local.region}${each.value.zone}"
  tags = {
    Name = each.key
  }
}
```

## Reasoning

Due to the many dynamically created resources, it is challenging to keep up with the required arguments for certain blocks. For instance, when using the for loop to create VPCs, it can be tricky to assign a particular VPC to a dynamically created resource unless the reference pattern is hard-coded in the variable. This could result in extensive variable files or even multiple such configurations.

By maintaining a consistent naming scheme throughout the configuration, it becomes more straightforward to assign values dynamically, deriving from dynamic resources.

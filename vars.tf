
# VPCs
variable "vpc" {
  type = object({
    web = string
    rds = string
    ao = string
  })

  default = {
    web = "10.0.0.0/16"
    rds = "172.16.0.0/24"
    ao = "192.168.0.0/24"
  }
}

# subnets
variable "subnets" {
  type = list(object({
    service = string  # e.g., "web", "rds", "ao"
    cidr_block = string
    zone = string  # e.g., "1a", "1b", "1c"
    public = bool    # e.g., true or false
  }))
}


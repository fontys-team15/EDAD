ec2 = [ {
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
    service = "Ansible"
    zone = "1a"
    instance_type = "t2.micro"
},
{
    service = "Terraform"
    zone = "1b"
    instance_type = "t2.micro"

},
{
    service = "web"
    zone = "1c"
    instance_type = "t2.micro"

} ]
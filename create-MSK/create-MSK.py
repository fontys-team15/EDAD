import json
import boto3
from jinja2 import Template

BUCKET = 'user-configurations'
INSTANCE_ID = 'i-0ea9bbf03dbaf01dd'

s3 = boto3.client('s3')

def read_template_from_file():
    s3_obj = s3.get_object(Bucket=BUCKET, Key='templates/cloud-formation.jinja2')
    template = s3_obj["Body"].read()
    s3_obj["Body"].close()
    return template.decode("utf-8")

def render_template(template_content, name, vpc_cidr, subnet_cidrs, brokers, broker_volume_size):
    template = Template(template_content)
    rendered_content = template.render(name=name, vpc_cidr=vpc_cidr, subnet_cidrs=subnet_cidrs, brokers=brokers, broker_volume_size=broker_volume_size)
    return rendered_content

def exec_template(rendered_template, email):
    cloudformation_client = boto3.client('cloudformation')

    response = cloudformation_client.create_stack(
        StackName=f"{email}",
        TemplateBody=rendered_template,
        Capabilities=['CAPABILITY_IAM']
    )
    return 200

def lambda_handler(event, context):
    print(event)
    email = event["email"]
    name = event["cluster_name"]
    vpc_cidr = event["vpc_cidr"]
    subnet_cidrs = event["subnet_cidrs"]
    print(subnet_cidrs)
    brokers = event["brokers"]
    broker_volume_size = event["broker_volume_size"]

    template_content = read_template_from_file()
    rendered_template = render_template(template_content, name, vpc_cidr, subnet_cidrs, brokers, broker_volume_size)
    print(rendered_template)

    exec_template(rendered_template, email)

    return {
        'status': 200
        }

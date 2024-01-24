import boto3
import socket
from jinja2 import Template

BUCKET = 'user-configurations'

s3 = boto3.client('s3')
def read_template_from_file():
    s3_obj = s3.get_object(Bucket=BUCKET, Key='templates/basic-page.jinja2')
    template = s3_obj["Body"].read()
    s3_obj["Body"].close()
    return template.decode("utf-8")

def render_template(template_content, hostname):
    template = Template(template_content)
    rendered_content = template.render(hostname = hostname)
    return rendered_content

def lambda_handler(event, context):
    template_content = read_template_from_file()
    rendered_content = render_template(template_content, socket.gethostname())

    return {
        "statusCode": 200,
        "body": rendered_content
    }

#change 4

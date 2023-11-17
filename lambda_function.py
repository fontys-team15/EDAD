import json
import boto3
from jinja2 import Template


def read_template_from_file():
    s3 = boto3.client('s3')
    s3_obj = s3.get_object(Bucket='user-configurations', Key='templates/args.tfvars.j2')
    args_template = s3_obj["Body"].read()
    s3_obj["Body"].close()

    return args_template.decode("utf-8")

def render_template(template_content, name, vpc_cidr, subnet_cidrs, brokers, broker_volume_size):
    template = Template(template_content)
    rendered_content = template.render(name=name, vpc_cidr=vpc_cidr, subnet_cidrs=subnet_cidrs, brokers=brokers, broker_volume_size=broker_volume_size)
    return rendered_content

def lambda_handler(event, context):
    name = json_data["name"]
    vpc_cidr = json_data["vpc_cidr"]
    subnet_cidrs = json_data["subnet_cidrs"]
    brokers = json_data["brokers"]
    broker_volume_size = json_data["broker_volume_size"]

    template_content = read_template_from_file()

    rendered_tf_args = render_template(template_content, name, vpc_cidr, subnet_cidrs, brokers, broker_volume_size)

    return rendered_tf_args.encode("utf-8")

def lambda_handler(event, context):
    instance_id = 'i-0ea9bbf03dbaf01dd'
    args = event
    print(args)
    script = f'echo -e {args} > /home/ssm-user/args.tfvars'

    ssm = boto3.client('ssm')

    params = {
        'InstanceIds': [instance_id],
        'DocumentName': 'AWS-RunShellScript',
        'Parameters': {
            'commands': [script]
        }
    }

    try:
        response = ssm.send_command(**params)
        command_id = response['Command']['CommandId']
        print(f'Command sent to EC2 instance. Command ID: {command_id}')
        return {
            'statusCode': 200,
            'body': 'Command sent successfully!'
        }
    except Exception as e:
        print(f'Error sending command to EC2 instance: {e}')
        return {
            'statusCode': 500,
            'body': 'Error sending command to EC2 instance.'
        }


# print(lambda_handler().encode("utf-8"))

print(write_to_node())
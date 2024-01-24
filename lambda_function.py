import time
import boto3
import json
from jinja2 import Template

BUCKET = 'user-configurations'

s3 = boto3.client('s3')
msk = boto3.client('kafka')
cloudformation_client = boto3.client('cloudformation')
def read_template_from_file():
    s3_obj = s3.get_object(Bucket=BUCKET, Key='templates/dashboard.jinja2')
    template = s3_obj["Body"].read()
    s3_obj["Body"].close()
    return template.decode("utf-8")

def render_template(template_content,name,body):
    template = Template(template_content)
    rendered_content = template.render(name=name,body=body)
    return rendered_content

def does_msk_cluster_exist(name):
    response = msk.list_clusters()

    for cluster in response['ClusterInfoList']:
        if cluster['ClusterName'] == name:
            return True

    return False


def exec_template(rendered_template, name):
    if not does_msk_cluster_exist(name):
        raise Exception(f"MSK Cluster with name {name} does not exist.")

    cloudformation_client = boto3.client('cloudformation')
    stack_name = f"{name}-{int(time.time())}"

    response = cloudformation_client.create_stack(
        StackName=stack_name,
        TemplateBody=rendered_template,
        Capabilities=['CAPABILITY_IAM']
    )

    # You can return the StackId or any other relevant information
    return {
        'status': 200,
        'stack_id': response['StackId']
    }

def lambda_handler(event, context):
    name = event["name"]
    region = "eu-central-1"
    DashboardBody = json.dumps(
    {
          "widgets": [
            {
              "type": "text",
              "x": 0,
              "y": 0,
              "width": 24,
              "height": 1,
              "properties": {
                "markdown": "## MSK Cluster Dashboard ->" + name
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 1,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/Kafka", "NetworkRxPackets", "Cluster Name", name, "Broker ID", "1", { "region": "eu-central-1" } ],
                  [ "...", "2", { "region": "eu-central-1" } ],
                  [ "...", "3", { "region": "eu-central-1" } ]
                ],
                "region": "eu-central-1",
                "view": "timeSeries",
                "stacked": False,
                "title": "Network RX packets by broker",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 1,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/Kafka", "CpuUser", "Cluster Name", name, "Broker ID", "1", { "region": "eu-central-1" } ],
                  [ "...", "2", { "region": "eu-central-1" } ],
                  [ "...", "3", { "region": "eu-central-1" } ] 
                ],
                "region": "eu-central-1",
                "view": "timeSeries",
                "stacked": False,
                "title": "CPU (User) usage by broker",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 1,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/Kafka", "KafkaDataLogsDiskUsed", "Cluster Name", name, "Broker ID", "1", { "region": "eu-central-1" } ],
                  [ "...", "2", { "region": "eu-central-1" } ],
                  [ "...", "3", { "region": "eu-central-1" } ]
                ],
                "region": "eu-central-1",
                "view": "timeSeries",
                "stacked": False,
                "title": "Disk usage by broker",
                "period": 300
              }
            },
            {
              "type": "metric",
              "x": 0,
              "y": 1,
              "width": 12,
              "height": 6,
              "properties": {
                "metrics": [
                  [ "AWS/Kafka", "NetworkTxPackets", "Cluster Name", name, "Broker ID", "1", { "region": "eu-central-1" } ],
                  [ "...", "2", { "region": "eu-central-1" } ],
                  [ "...", "3", { "region": "eu-central-1" } ]
                ],
                "region": "eu-central-1",
                "view": "timeSeries",
                "stacked": False,
                "title": "Network TX packets by broker",
                "period": 300
              }
            }
          ]
    })
    escapedDashboardBody = json.dumps(DashboardBody)
    if not name:
        return {
            'status': 400,
            'message': 'MSK cluster name is required in the input.'
        }
    if not does_msk_cluster_exist(name):
        return {
            'status': 404,
            'message': f'MSK Cluster with name {name} does not exist.'
        }
    template_content = read_template_from_file()
    rendered_template = render_template(template_content,name,escapedDashboardBody)
    exec_template(rendered_template, name)
    time.sleep(20)
    dashboard_url = f"https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#dashboards/dashboard/{name}"
    return {
        'status': 200,
        'body': json.dumps({'dashboard_url': dashboard_url})
    }


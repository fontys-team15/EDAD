import boto3

def lambda_handler(event, context):
    stack_name = event.get('name')

    if not stack_name:
        print("Error: Stack name not provided in the input.")
        return

    cf_client = boto3.client('cloudformation')

    try:
        response = cf_client.delete_stack(StackName=stack_name)
        print(f"Stack deletion initiated: {response}")
    except Exception as e:
        print(f"Error deleting stack: {e}")

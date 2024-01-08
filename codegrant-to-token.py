import requests
import jsonify
#import boto3


'''
1. receives request with code grant (should be in the event body)
2. exchanges the code for a token by hitting the oauth2 endpoint
3. pass the token to the next lambda
'''

ENDPOINT = "https://auth.sigmadad.fitness/oauth2/token"
HEADERS = {'Content-Type': 'application/x-www-form-urlencoded'}

def exchange_for_token(cgrant: str):
    data = {
        'grant_type': 'authorization_code',
        'client_id': '7islnjaa6l6ch9ughu2v1v7cj7',
        'code': f'cgrant',
        'redirect_uri': 'https://www.google.com',
        'scope': 'auth/msk'
    }
    r = request.get(ENDPOINT, headers=HEADERS, data=data) 
    print(r)
    return TOKEN

def lambda_handler(event, context):
    cgrant = event[]
    token = exchange_for_token()

    return jsonify({
        'status': 200,
        'token': token 
    })


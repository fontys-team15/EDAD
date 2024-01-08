import requests

ENDPOINT = "https://auth.sigmadad.fitness/oauth2/token"
HEADERS = {'Content-Type': 'application/x-www-form-urlencoded'}

def exchange_for_token(cgrant: str):
    data = {
        'grant_type': 'authorization_code',
        'client_id': '7islnjaa6l6ch9ughu2v1v7cj7',
        'code': cgrant,
        'redirect_uri': 'https://www.google.com',
        'scope': 'auth/msk'
    }
    r = requests.post(ENDPOINT, headers=HEADERS, data=data) 
    return r.json() 

def lambda_handler(event, context):
    cgrant = event
    token = exchange_for_token(cgrant)
    return {
        'status': 200,
        'token': token["id_token"]
    }

print(lambda_handler(input(),3))

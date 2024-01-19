#!/bin/python3
import requests
import json

identityPoolId = "eu-central-1:5ed864cd-7650-4e8e-9933-078cec32a065"

# Code Grant exchange Action constants
TOKEN_ENDPOINT = "https://auth.sigmadad.fitness/oauth2/token"
TOKEN_HEADERS = {'Content-Type': 'application/x-www-form-urlencoded'}
TOKEN_BODY = {
    'grant_type': 'authorization_code',
    'client_id': '7islnjaa6l6ch9ughu2v1v7cj7',
    'code': "",
    'redirect_uri': 'https://www.google.com',
    'scope': 'auth/msk'
}

# GetId Action constants
COGNITO_IDP_ENDPOINT = "https://cognito-identity.eu-central-1.amazonaws.com/"


IDP_HEADERS_GETID = {
    'CONTENT-TYPE': 'application/x-amz-json-1.1', 
    'X-AMZ-TARGET': 'com.amazonaws.cognito.identity.model.AWSCognitoIdentityService.GetId'
}

# Modify the Action variable for GetCredentialsForIdentity
IDP_HEADERS_GETCREDS = {
    'CONTENT-TYPE': 'application/x-amz-json-1.1', 
    'X-AMZ-TARGET': 'com.amazonaws.cognito.identity.model.AWSCognitoIdentityService.GetCredentialsForIdentity'
}



def exchangeCodeGrant(cgrant: str):
    TOKEN_BODY["code"] = cgrant
    r = requests.post(TOKEN_ENDPOINT, headers=TOKEN_HEADERS, data=TOKEN_BODY) 
    #print(r.json())
    return r.json() 

def getId(idpID, idToken):
    GETID_BODY = {
        "IdentityPoolId": idpID,
        "Logins": {
            "cognito-idp.eu-central-1.amazonaws.com/eu-central-1_LHhCwDtel": idToken
        }
    }

    try:
        # Make the request
        r = requests.post(COGNITO_IDP_ENDPOINT, headers=IDP_HEADERS_GETID, data=json.dumps(GETID_BODY))

        # Print the JSON response
        print(r.json())

        # Return the JSON response
        return r.json()
    except Exception as e:
        print(f"Error: {e}")
        raise  # Re-raise the exception to propagate it further

def getCredentialsForIdentity(identityID, idToken):
    GETCREDS_BODY = {
        "IdentityId": identityID,
        "Logins": {
            "cognito-idp.eu-central-1.amazonaws.com/eu-central-1_LHhCwDtel": idToken
        }
    }

    print(json.dumps(GETCREDS_BODY))
    try:
        # Make the request

        r = requests.post(COGNITO_IDP_ENDPOINT, headers=IDP_HEADERS_GETCREDS, data=json.dumps(GETCREDS_BODY))

        # Print the JSON response
        print(r.json())

        # Return the JSON response
        return r.json()
    except Exception as e:
        print(f"Error: {e}")
        raise  # Re-raise the exception to propagate it further

def lambda_handler(event, context):
    cgrant = event
    idToken = exchangeCodeGrant(cgrant)["id_token"]
    identityId = getId(identityPoolId, idToken)["IdentityId"]
    creds = getCredentialsForIdentity(identityId, idToken)
    return {
        'status': 200,
        'id_token': idToken,
        'creds': creds
    }


print(lambda_handler(input(),3))

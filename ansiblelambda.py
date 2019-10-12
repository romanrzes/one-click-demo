import json
import requests
import os
import boto3
import base64
from botocore.exceptions import ClientError


def get_secret():

    secret_name = "token"
    region_name = "eu-central-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
    print("after client")

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        print("try")
        # print(get_secret_value_response)
    except ClientError as e:
        print("except")
        print(e)
        if e.response['Error']['Code'] == 'DecryptionFailureException':
            print("DecryptionFailureException")
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InternalServiceErrorException':
            print("InternalServiceErrorException")
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidParameterException':
            print("InvalidParameterException")
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'InvalidRequestException':
            print("InvalidRequestException")
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response['Error']['Code'] == 'ResourceNotFoundException':
            print("ResourceNotFoundException")
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
            print("secretstring")
        else:
            decoded_binary_secret = base64.b64decode(get_secret_value_response['SecretBinary'])
            print("decoded")

    print("end")
    return secret


token = json.loads(get_secret())["token"]
url = "http://18.185.132.129:8080/generic-webhook-trigger/invoke?token=" + token
# print(get_secret())

def lambda_handler(event, context):
    # js = json.loads(token)
    # js["token"]
    # print(token)
    requests.get(url)

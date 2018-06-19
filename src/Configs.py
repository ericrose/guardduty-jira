import os
import yaml
import boto3
import json
from botocore.exceptions import ClientError

class Configs(object):

    @staticmethod
    def get():
        file_name = os.path.join(os.path.dirname(__file__), 'configs.yml')
        configs = {}
        with open(file_name, 'r') as configs:
            configs =  yaml.load(configs) 
        
        print(configs)

        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=configs['region'],
            endpoint_url="https://secretsmanager.{}.amazonaws.com".format(configs['region'])
        )
    
        try:
            get_secret_value_response = client.get_secret_value(
                SecretId=configs['secret_name']
            )
        except ClientError as e:
            if e.response['Error']['Code'] == 'ResourceNotFoundException':
                print("The requested secret " + configs['secret_name'] + " was not found")
            elif e.response['Error']['Code'] == 'InvalidRequestException':
                print("The request was invalid due to:", e)
            elif e.response['Error']['Code'] == 'InvalidParameterException':
                print("The request had invalid params:", e)
        else:
            # Decrypted secret using the associated KMS CMK
            # Depending on whether the secret was a string or binary, one of these fields will be populated
            if 'SecretString' in get_secret_value_response:
                secret = get_secret_value_response['SecretString']
                configs = {**json.loads(secret), **configs}
            else:
                binary_secret_data = get_secret_value_response['SecretBinary']
                configs = {**json.loads(binary_secret_data), **configs}
        return(configs)    
            
if __name__ == "__main__":
    #get_secret()
    print(Configs.get())
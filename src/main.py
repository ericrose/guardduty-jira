import json
from pprint import pprint
from Ticket import Ticket

def lambda_handler(event, context):
    main(event, is_lambda=True)

def main(event, is_lambda=True):
    message = event['detail']
    try:
        ticket = Ticket(message, is_lambda)
        ticket.create()
    except Exception as e:
        print('Error: {0}'.format(e))


if __name__ == '__main__':
    with open('../tests/sample.json') as f:
        event = json.load(f)
    main(event, is_lambda=False)

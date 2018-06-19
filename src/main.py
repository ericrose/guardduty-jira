import json
from pprint import pprint
from Ticket import Ticket

def lambda_handler(event, context):
    main(event, is_lambda=True)

def main(event, is_lambda=True):
    message = event['detail']
    try:
        #if PagerDuty.is_triggered_alert(message_data) and not Ticket.exists(message_data):  
        ticket = Ticket(message, is_lambda)
        ticket.create()
         # TODO update_pager_duty_with_ticket_info()
    except Exception as e:
        print('Error: {0}'.format(e))


if __name__ == '__main__':
    with open('../tests/sample.json') as f:
        event = json.load(f)
    #pprint(event)    
    main(event, is_lambda=False)

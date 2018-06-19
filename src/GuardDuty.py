from Configs import Configs
from BaseClass import BaseClass


class GuardDuty(BaseClass):

    @staticmethod
    def is_triggered_alert(data):
        return True
    #    try:
    #        return data['incident']['status'] == 'triggered'
    #    except Exception as e:
    #        return False

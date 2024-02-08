import json
import re
from risks.risk import Risk

class Verbiage:
    def __init__(self, model_name, dictionary):
        with open('./nlp/verbiage.json', 'r') as myfile:
            data = myfile.read()
        models_verbiages = json.loads(data)
        self._verbiage = models_verbiages[model_name]

    def get_verbiage(self, key):
        if key in self._verbiage:
            return self._verbiage[key]
        else:
            return key

    def get_risk_verbiage(self, risk: 'Risk', dictionary):
        return self.decorate_verbiage(risk, dictionary)

    def decorate_verbiage(self, risk: 'Risk', dictionary):
        verbiage = self.get_verbiage(risk.name)
        dictionary["DAY"] = "daily"
        dictionary["HOUR_4"] = "4 hour"
        dictionary["MINUTE_15"] = "15 minute"
        dictionary["HOUR"] = "1 hour"

        
    
        word_list = set(verbiage.split())

        if '{loss}' in word_list or '{loss},' in word_list or '{loss}.' in word_list:
            verbiage = re.sub('{loss}', str(round(float(risk.get_param2('param_6')),4)), verbiage, 1)
        if '{gain}' in word_list or '{gain},' in word_list or '{gain}.' in word_list:
            verbiage = re.sub('{gain}', str(round(float(risk.get_param2('param_6')), 4)), verbiage, 1)
        if '{deal1}' in word_list or '{deal1},' in word_list or '{deal1}.' in word_list:
            verbiage = re.sub('{deal1}', risk.get_param2('ot_pos_dealid'), verbiage, 1)
        if '{name1}' in word_list or '{name1},' in word_list or '{name1}.' in word_list:
            verbiage = re.sub('{name1}',risk.get_param2('name_1'), verbiage, 1)
        if '{deal2}' in word_list or '{deal2},' in word_list or '{deal2}.' in word_list:
            verbiage = re.sub('{deal2}',risk.get_param2('param_1'), verbiage, 1)
        if '{name2}' in word_list or '{name2},' in word_list or '{name2}.' in word_list:
            verbiage = re.sub('{name2}', risk.get_param2('param_3'), verbiage, 1)
        if '{diver}' in word_list or '{diver},' in word_list or '{diver}.' in word_list:
            verbiage = re.sub('{diver}', risk.get_param2('param_2'), verbiage, 1)
        if '{perc}' in word_list or '{perc},' in word_list or '{perc}.' in word_list:
            verbiage = re.sub('{perc}', risk.get_param2('param_2'), verbiage, 1)
        if '{rrr}' in word_list or '{rrr},' in word_list or '{rrr}.' in word_list:
            verbiage = re.sub('{rrr}', risk.get_param2('param_2'), verbiage, 1)
        if '{name1}' in word_list or '{name1},' in word_list or '{name1}.' in word_list:
            verbiage = re.sub('{name1}', dictionary[risk.get_param2('param_5')], verbiage, 1)
        if '{name2}' in word_list or '{name2},' in word_list or '{name2}.' in word_list:
            verbiage = re.sub('{name2}',dictionary[risk.get_param2('param_6')], verbiage, 1)
        if '{timeframe}' in word_list or '{timeframe},' in word_list or '{timeframe}.' in word_list:
            verbiage = re.sub('{timeframe}', dictionary[risk.get_param2('param_6')], verbiage, 1)
        if '{quantity}' in word_list or '{quantity},' in word_list or '{quantity}.' in word_list:
            verbiage = re.sub('{quantity}', risk.get_param2('param_2'), verbiage, 1)

        return verbiage

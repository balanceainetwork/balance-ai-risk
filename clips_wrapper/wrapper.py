import re
from typing import List

import clips
from clips import CLIPSError

from correlation.matrix import CorrelationMatrix
from risks.risk import Risk


class ClipsWrapper:
    MODELS_PATH = './ai_models/'
    MODELS_EXT = '.clp'

    RISK_FACT_NAME = 'risk-is'
    RISK_FACT_DATA = 'risk-data'
    RISK_DEAL_ASSET_NAME = 'ot_pos_dealid'
    RISK_CORRELATION_DATA = 'correlation-data'

    corr_matrix = CorrelationMatrix()

    @staticmethod
    def regex_match(pattern, string):
        """Match pattern against string returning a multifield
        with the first element containing the full match
        followed by all captured groups.

        """
        match = re.match(pattern, string)
        if match is not None:
            return (match.group(),) + match.groups()
        else:
            return []

    @staticmethod
    def check_pos_corr(asset1, asset2):
        return ClipsWrapper.corr_matrix.check_pos_corr(str(asset1), str(asset2))

    @staticmethod
    def check_neg_corr(asset1, asset2):
        return ClipsWrapper.corr_matrix.check_neg_corr(str(asset1), str(asset2))

    def __init__(self, model):
        self._env = clips.Environment()
        self._env.define_function(ClipsWrapper.regex_match)
        self._env.define_function(ClipsWrapper.check_pos_corr)
        self._env.define_function(ClipsWrapper.check_neg_corr)
        self._env.load(ClipsWrapper.MODELS_PATH + model + ClipsWrapper.MODELS_EXT)
        self.model_name = model

    def set_correlation_matrix(self, correlation_matrix_json):
        self.corr_matrix.set(correlation_matrix_json)

    def build(self, model):
        self._env.clear()
        self._env.reset()
        self._env.build(model)

    def build_fact(self, key, value):
        return '(' + key + ' ' + value + ')'

    def build_position_data(self, data):
        position_data = '( position-data '
        for d in data:
            position_data += '(' + d[0] + ' ' + d[1] + ')'
        position_data += ')'
        return position_data

    def add_fact(self, fact_string: 'String'):
        try:
            self._env.assert_string(fact_string)
        except CLIPSError:
            # Add loggging
            pass

    def run(self):
        try:
            self._env.run()
        except CLIPSError:
            # Add loggging
            pass

    def reset(self):
        self._env.reset()

    def get_risks(self) -> List[Risk]:
        buf = []
        for fact in self._env.facts():
            r = ClipsWrapper.get_risk(fact)
            if r is not None:
                buf.append(r)

        return buf

    def define_function(self, function):
        self._env.define_function(function)

    def evaluate(self, pattern):
        return self._env.eval(pattern)

    @staticmethod
    def get_risk(fact: 'Fact'):
        fact_str = ClipsWrapper.sanitize_fact(str(fact))

        fact_str = fact_str.replace('(', '').replace(')', '')
        fact_array = fact_str.split()

        if len(fact_array) == 0:
            return None

        if fact_array[0] == ClipsWrapper.RISK_FACT_NAME:
            if len(fact_array) == 2:
                return Risk(fact_array[1], None)

        if fact_array[0] == ClipsWrapper.RISK_FACT_DATA:
            params = []
            params2 = {}

            for i in range(len(fact_array)):
                if fact_array[i] == ClipsWrapper.RISK_FACT_NAME:
                    r_name = fact_array[i + 1]
                elif fact_array[i] == ClipsWrapper.RISK_DEAL_ASSET_NAME:
                    r_asset = fact_array[i + 1]
                    if r_asset != "nil":
                        params.append(r_asset)
                elif fact_array[i] is not None and fact_array[i].startswith("param_"):
                    param = fact_array[i + 1]
                    if param != "nil":
                        params.append(param)

            for i in range(3, len(fact_array), 2):
                params2[fact_array[i]] = fact_array[i + 1]
            return Risk(r_name, params, params2)

    # Remove f-10, f- at the beggining of fact text
    # Probably a bug in clipsy
    @staticmethod
    def sanitize_fact(f):
        return "(" + f.split("(", 1)[1]

    def print_facts(self):
        for fact in self._env.facts():
            print(ClipsWrapper.sanitize_fact(str(fact)))

    def print_risks(self):
        ra = self.get_risks()
        for r in ra:
            print(r.name)

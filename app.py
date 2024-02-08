import json
import logging
import time
import atexit

from flask import Flask, request, jsonify, make_response

from clips_wrapper.wrapper import ClipsWrapper

from nlp.verbiage import Verbiage
from util import tools

LOG_FORMAT = ('%(levelname) -10s %(asctime)s %(name) -30s %(funcName) '
              '-35s %(lineno) -5d: %(message)s')

logger = logging.getLogger(__name__)

flask_app = Flask(__name__)

application = flask_app

config_data = tools.read_json('./config_balance.json')

model_name = config_data['ot_model']
logger.info("Running with model = " + config_data['ot_model'])
clips_wrapper = ClipsWrapper(model=model_name)

# Dictionary for instrument names because clips does not accept
instrument_dict = {}

verbiage_tool = Verbiage(model_name, instrument_dict)


@flask_app.route('/', methods=['GET', 'POST'])
def health():
    return jsonify({"status": "ok"})


@flask_app.route('/risks', methods=['GET', 'POST'])
def get_risks():
    payload = request.json

    clips_wrapper.reset()

    if 'ot_user_id' in payload:
        user_id = payload['ot_user_id']
    else:
        user_id = -1

    print(f'Payload = {payload}')

    # ot_risk_input
    # ot_user_profile
    # ot_correlation_matrix

    if 'ot_correlation_matrix' in payload:
        clips_wrapper.set_correlation_matrix(payload['ot_correlation_matrix'])

    if 'ot_risk_input' in payload:
        parse_risk_input(payload['ot_risk_input'])
    else:
        # Parse as in the old times
        parse_risk_input(payload)

    if 'ot_user_profile' in payload:
        parse_risk_input(payload['ot_user_profile'])

    # ot_indicators
    ot_indicators = []
    if 'ot_indicators' in payload:
        parse_indicators(payload['ot_indicators'])
        ot_indicators = payload['ot_indicators']

    clips_wrapper.run()

    clips_wrapper.print_facts()

    risks = clips_wrapper.get_risks()

    risk_verbiage = []
    for r in risks:
        print('***** RISK -> ' + r.name)
        risk_verbiage.append({r.name: verbiage_tool.get_risk_verbiage(r, instrument_dict)})

    t = time.time()
    r_s = str(user_id) + "_" + str(int(t))
    json_response = json.dumps(
        {
            "ot_user_id": user_id,
            "ot_timestamp": t,
            "ot_risk_answer_signature": r_s,
            "identified_risks": risk_verbiage,
            "ot_indicators": ot_indicators
        })

    headers = {"Content-Type": "application/json"}

    return make_response(json_response, 200, headers)


def parse_indicators(indicators_payload):
    for indicator in indicators_payload:
        inner_facts = ''
        for (k, v) in indicator.items():
            inner_facts += clips_wrapper.build_fact(k, str(v))
        fact = clips_wrapper.build_fact('indicator-data', inner_facts)
        print('********* ' + fact)
        clips_wrapper.add_fact(fact)


def parse_risk_input(payload):
    for (k, v) in payload.items():
        # do not process habits in that risk model
        if k == 'identified_habits':
            continue
        print("Key: " + k)
        print("Value: " + str(v))
        if k != 'position-data':
            fact = clips_wrapper.build_fact(k, str(v))
            clips_wrapper.add_fact(fact)
        else:
            if len(payload['position-data']) == 1:
                build_outer_position_data(payload['position-data'][0])
            else:
                for position in payload['position-data']:
                    build_outer_position_data(position)


def build_outer_position_data(payload):
    buf = []
    global instrument_dict
    if type(payload) == str:
        return
    for (ik, iv) in payload.items():
        val = str(iv)
        val = val.replace(' ', '_')
        val = val.replace('(', '')
        val = val.replace(')', '')
        val = val.replace('$', '')
        buf.append([ik, val])
        if ik == 'ot_instr_name':
            global instrument_dict
            print(str(iv))
            instrument_dict.update({val: iv})

    fact = clips_wrapper.build_position_data(buf)
    print('********** ' + fact)
    clips_wrapper.add_fact(fact)


if __name__ == '__main__':
    application.run()

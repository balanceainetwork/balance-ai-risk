
import json
import logging


LOG_FORMAT = ('%(levelname) -10s %(asctime)s %(name) -30s %(funcName) '
              '-35s %(lineno) -5d: %(message)s')
LOGGER = logging.getLogger(__name__)

def read_json(file):
    try:
        with open(file, 'r') as myfile:
            data = myfile.read()

        # parse file
        obj = json.loads(data)
        return obj

    except FileNotFoundError as e:
        LOGGER.error('Error:' + str(e))
        return None



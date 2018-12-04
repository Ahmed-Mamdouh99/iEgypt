"""
This script runs the iEgypt application using a development server.
"""
import datetime
from iEgypt import app
from iEgypt.config import config


if __name__ == '__main__':
    hostname = config.get('hostname')
    port = config.get('port')
    app.secret_key = '1'#str(datetime.datetime.now())
    try:
        app.run(hostname, port)
    except KeyboardInterrupt:
        import os
        os._exit(0)

"""
This script runs the iEgypt application using a development server.
"""
from iEgypt import app
from iEgypt.config import config


if __name__ == '__main__':
    hostname = config.get('hostname')
    port = config.get('port')
    app.secret_key = 'secret'
    app.run(hostname, port)

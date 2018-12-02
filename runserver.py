"""
This script runs the iEgypt application using a development server.
"""
from iEgypt import app
from iEgypt.config import config


def set_database_procedures():
    from iEgypt.model.db import get_conn
    conn = get_conn()
    cursor = conn.cursor()
    with open('dump.sql') as dump:
        for command in dump.read().split('GO'):
            cursor.execute(command)
    conn.close()


if __name__ == '__main__':
    hostname = config.get('hostname')
    port = config.get('port')
    app.secret_key = 'secret'
    set_database_procedures()
    try:
        app.run(hostname, port)
    except KeyboardInterrupt:
        import os
        from iEgypt.blueprints.auth import clear_session
        clear_session()
        os._exit(0)

import pyodbc
from iEgypt.model.db import get_conn
from iEgypt.config import config

def get_server_conn():
    """Return a new connection"""

    if config.get('OS').lower() == 'windows':
        conn = pyodbc.connect(driver='{SQL Server}', Trusted_Connection='yes',
            server=config.get('db_server'), autocommit=True)
        return conn

    elif config.get('OS').lower() == 'linux':
        conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "UID="+str(config.get('db_username'))+";"
            "PWD="+str(config.get('db_password'))+";"
            "SERVER="+str(config.get('db_server'))+";"
            "port="+str(config.get('db_port'))+";"
        )
        conn = pyodbc.connect(conn_str, autocommit=True)
        return conn
    

with get_server_conn() as conn:
    cursor = conn.cursor()
    cursor.execute('CREATE DATABASE '+config.get('db_name'))

#Creating the tables
with get_conn() as conn:
    cursor = conn.cursor()
    with open('tables.sql') as file:
        for command in file.read().split('GO'):
            cursor.execute(command)

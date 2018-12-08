import pyodbc
from iEgypt.config import config


def get_conn():
    """Return a new connection"""
	
    if config.get('OS').lower() == 'windows':
        conn = pyodbc.connect(driver='{SQL Server}', Trusted_Connection='yes',
            server=config.get('db_server'), database=config.get('db_name'), autocommit=True)
        return conn

    elif config.get('OS').lower() == 'linux':
        conn_str = (
            "DRIVER={ODBC Driver 17 for SQL Server};"
            "DATABASE="+str(config.get('db_name'))+";"
            "UID="+str(config.get('db_username'))+";"
            "PWD="+str(config.get('db_password'))+";"
            "SERVER="+str(config.get('db_server'))+";"
            "port="+str(config.get('db_port'))+";"
        )
        conn = pyodbc.connect(conn_str, autocommit=True)
        return conn

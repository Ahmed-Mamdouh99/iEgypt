import yaml


def get_default_config():
    default_config = { 'hostname':'localhost', 'port':'3000', \
    'db_server':'Express', 'db_username':'SA', \
    'db_password':'YourStrongPassword123', \
    'db_name':'IEgypt_78', 'db_port':'1433', \
    'db_driver':'{ODBC Driver 13 for SQL Server}'
    }
    return default_config


config = get_default_config()


with open('config.yml', 'r') as conf:
    try:
        config = yaml.load(conf)
    except yaml.YAMLError:
        pass

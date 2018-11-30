import yaml


def get_default_config():
    default_config = { 'hostname':'localhost', 'port':'3000',
    'db_server':'Express', 'db_username':'SA',
    'db_password':'YourStrongPassword123'}
    return default_config


config = get_default_config()


with open('../config.yml', 'r') as conf:
    try:
        config = yaml.load(conf)
    except yaml.YAMLError:
        pass

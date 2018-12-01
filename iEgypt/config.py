import yaml


config = None


with open('config.yml', 'r') as conf:
    try:
        config = yaml.load(conf)
    except yaml.YAMLError:
        pass

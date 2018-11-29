"""
The flask application package.
"""
from flask import Flask
app = Flask(__name__)


#Registering blueprints
from iEgypt.blueprints import user, auth
app.register_blueprint(user.bp, url_prefix=('/'))
app.register_blueprint(auth.bp, url_prefix=('/'))

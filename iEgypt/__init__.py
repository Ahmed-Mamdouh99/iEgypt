"""
The flask application package.
"""
from flask import Flask, session
from iEgypt.model.overloaded import load_template
from iEgypt.model.db.user_model import get_user_name


app = Flask(__name__)


# Registering blueprints
from iEgypt.blueprints import user, viewer
app.register_blueprint(user.bp, url_prefix=('/'))
app.register_blueprint(viewer.bp, url_prefix=('/'))


# Adding custom error pages
@app.errorhandler(403)
def unauthorized_access(e):
    name = 'Mario'
    if session.get('user_id'):
        name = get_user_name(session.get('user_id'))
    return load_template('errors/403.html', title='403 - Unauthorized access', name=name)


@app.errorhandler(404)
def page_not_found(e):
    return load_template('errors/404.html', title='404 - Page not found')


@app.errorhandler(500)
def internal_server_error(e):
    return load_template('errors/500.html', title='500 - Internal server error')

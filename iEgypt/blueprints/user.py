"""
Routes and views for the flask application.
"""
from flask import (
    Blueprint, session, redirect, url_for
)
from iEgypt.model.overloaded import load_template


#Create the blueprint
bp = Blueprint('user', __name__, url_prefix='/')


@bp.route('/')
@bp.route('/home')
def home():
    """Renders the home page."""
    if session.get('user_id'):
        home_url = '{user_type}.index'.format(user_type=session.get('user_type'))
        return redirect(url_for(home_url))
    return load_template('user/home.html', title='Home')


@bp.route('/oc-search', methods=('GET', 'POST'))
def original_content_search():
    """Renders the page to search for original content"""
    return load_template('user/oc-search.html', title='Search Original Content')


@bp.route('/contributor-search', methods=('GET', 'POST'))
def contributor_search():
    """Renders the page to search for contributors"""
    return load_template('user/contributor-search.html', title='Search Contributor')


@bp.route('/show-contributors')
def show_contributors():
    """Renders the page to show contributors in order of
    highest years of experience"""
    return load_template('user/show-contributors.html', title='Show Contributors')

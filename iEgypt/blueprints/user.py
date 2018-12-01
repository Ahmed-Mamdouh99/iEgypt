"""
Routes and views for the flask application.
"""
from flask import (
    Blueprint, session, redirect, url_for, request
)
from iEgypt.model.overloaded import load_template
from iEgypt.model.db import user_search_oc, user_search_contributor


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
def oc_search():
    """Renders the page to search for original content"""
    col_names = ['Content ID', 'Contributor ID', 'Category', 'Subcategory', 'Type', 'Link', 'Rating']
    table = dict()
    if request.method == 'POST':
        type = 'NULL'
        cat = 'NULL'
        if request.form['type'] != '':
            type = request.form['type']
        if request.form['category'] != '':
            cat = request.form['category']
        table = user_search_oc(type, cat)
    return load_template('user/oc-search.html', title='Search Original Content', table=table, col_names=col_names)


@bp.route('/contributor-search', methods=('GET', 'POST'))
def contributor_search():
    """Renders the page to search for contributors"""
    return load_template('user/contributor-search.html', title='Search Contributor')


@bp.route('/show-contributors')
def show_contributors():
    """Renders the page to show contributors in order of
    highest years of experience"""
    return load_template('user/show-contributors.html', title='Show Contributors')

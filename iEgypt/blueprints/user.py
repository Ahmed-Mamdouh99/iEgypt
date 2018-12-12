"""
Routes and views for the flask application.
"""
from flask import Blueprint, session, redirect, url_for, request, flash, g
from iEgypt.model.overloaded import load_template
from iEgypt.model.db import user_model
from iEgypt.model.auth import login_required


#Create the blueprint
bp = Blueprint('user', __name__, url_prefix='/')


@bp.before_app_request
def load_logged_in_user():
    """If a user_id is stored in the session, load the user object from the databse into ``g.user``."""
    user_id = session.get('user_id')
    if user_id:
        g.user = user_id
        g.user_type = session.get('user_type')
    else:
        g.user = None
        g.user_type = None


@bp.route('/login', methods=('GET', 'POST'))
def login():
    """Log in a registered user by adding the user_id to the session."""
    if request.method == 'POST':
        email = request.form['email'].replace("'", '')
        password = request.form['password'].replace("'", '')
        user_id = user_model.login(email, password)
        error = None
        if not user_id:
            error = 'User does not exist.'
        elif user_id == -1:
            error = 'This account has been deactivated'
        if not error:
            # Store the user_id in a new session and go to index
            session.clear()
            session['user_id'] = user_id
            session['user_type'] = user_model.get_user_type(user_id)
            return redirect(url_for('user.home'))
        print('ERROR', error)
        flash(error)
    return load_template('user/login.html', title='Login')


@bp.route('/register', methods=('GET', 'POST'))
def register():
    """Register a new user. Validates that the email is not already registered."""
    if request.method == 'POST':
        params = dict()
        for key in request.form:
            params[key] = request.form[key].replace("'", '')
        user_id = user_model.register(**params)
        error = None
        if not user_id:
            error = 'Invalid data.'
        elif user_id == -1 :
            error = 'Email already registered.'
        if not error:
            session.clear()
            session['user_id'] = user_id
            session['user_type'] = request.form['type']
            return redirect(url_for('user.home'))
        flash(error)

    return load_template('user/register.html', title='Register')


@bp.route('/logout')
def logout():
    """Clear the current session, including the stored user_id."""
    session.clear()
    return redirect(url_for('user.index'))


@bp.route('/deactivate')
def deactivate():
    user_id = session.get('user_id')
    user_model.deactivate_profile(user_id)
    session.clear()
    return load_template('user/deactivated.html')


@bp.route('/')
def index():
    """Renders the home page."""
    return load_template('user/home.html', title='Home')


@bp.route('/home')
def home():
    """Renders the home page."""
    if session.get('user_id'):
        home_url = '{user_type}.index'.format(user_type=session.get('user_type'))
        return redirect(url_for(home_url))
    return load_template('user/home.html', title='Home')


@bp.route('/search-oc', methods=('GET', 'POST'))
def search_oc():
    """Renders the page to search for original content"""
    col_names = ['content id', 'category type', 'type', 'link', 'rating', \
    'contributor id']
    type = None
    category = None
    if request.method == 'POST':
        if request.form['type'] != '':
            type = request.form['type'].replace("'", '')
        if request.form['category'] != '':
            type = request.form['category'].replace("'", '')
    table = user_model.search_oc(type=type, category=category)
    return load_template('user/search-oc.html', title='Search Original Content',
        table=table, col_names=col_names)


@bp.route('/contributor-search', methods=('GET', 'POST'))
def contributor_search():
    """Renders the page to search for contributors"""
    col_names = ['id', 'full name', 'age', 'years of experience',
        'portfolio link', 'specialization']
    name = None
    if request.method == 'POST':
        if request.form['name'] != '':
            name = request.form['name'].replace("'", '')
    table = user_model.contributor_search(name)
    return load_template('user/contributor-search.html',
        title='Search Contributor', table=table, col_names=col_names)


@bp.route('/show-contributors')
def show_contributors():
    """Renders the page to show contributors in order of
    highest years of experience"""
    col_names = ['id', 'full name', 'age', 'years of experience',
        'specialization', 'portfolio link']
    table = user_model.order_contributor()
    return load_template('user/show-contributors.html',
        title='Show Contributors', table=table, col_names=col_names)


@bp.route('/show-oc', methods=('GET', 'POST'))
def show_oc():
    """Renders a page to show original content"""
    col_names = ['content id', 'category type', 'subcategory', 'year', 'rating',
        'full name', 'email', 'birthday', 'age', 'years of experience',
        'portfolio link']
    id = None
    if request.method == 'POST':
        if request.form['id'] != '':
            id = request.form['id'].replace("'", '')
    table = user_model.show_original_content(id=id)
    return load_template('user/show-oc.html', title='Show Original Content',
        table=table, col_names=col_names)


@bp.route('/show-profile')
@login_required
def show_profile():
    """Renders a page to show a user's profile"""
    user_id = session.get('user_id')
    user_type = session.get('user_type')
    labels = user_model.show_profile(user_id=user_id, user_type=user_type)

    return load_template('user/show-profile.html', labels=labels)


@bp.route('/edit-profile', methods=('GET', 'POST'))
@login_required
def edit_profile():
    """Renders a page to edit a user's profile"""
    user_id = session.get('user_id')
    user_type = session.get('user_type')
    if request.method == 'POST':
        user_keys = ('email', 'first name', 'middle name', 'last name',
        'password', 'birthday')
        other_data = dict()
        user_data = dict()
        for key in request.form.keys():
            if key in user_keys and request.form[key] != '':
                user_data[key] = request.form[key].replace("'", '')
            elif (not key in user_keys) and request.form[key] != '':
                other_data[key] = request.form[key].replace("'", '')
        if len(other_data) > 0 or len(user_data) > 0:
            user_model.edit_profile(user_id, user_type, user_data, other_data)

    labels = user_model.show_profile(user_id, user_type)
    return load_template('user/edit-profile.html', labels=labels)

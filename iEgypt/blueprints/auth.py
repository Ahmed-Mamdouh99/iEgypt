import functools
from flask import(
   redirect, Blueprint, g, session, request, abort, url_for, flash
   )

from iEgypt.model.db.auth_model import get_user, user_edit_profile, get_user_type, register_user
from iEgypt.model.overloaded import load_template

# Create the blueprint
bp = Blueprint('auth', __name__, url_prefix='/')


#Wrapper to check login
def login_required(view):
    """View decorator that redirects anonymous users to the login page."""
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('auth.login'))

        return view(**kwargs)

    return wrapped_view


def clear_session():
    session.clear()


# Wrapper to check account type
def account_type_required(type, view):
    """View decorator that verifies the account type."""
    @functools.wrape(view)
    def wrapped_view(**kwargs):
        if not g.user_type or g.user_type != type:
            #redirect to error page 403 unauthorized access
            abort(403)

        return view(**kwargs)

    return wrapped_view


# If a user is logged then load the user
@bp.before_app_request
def load_logged_in_user():
    """If a user id is stored in the session, load the user object from the databse into ``g.user``."""
    user_id = session.get('user_id')
    if user_id:
        g.user = user_id
        g.user_type = session.get('user_type')
    else:
        g.user, g.user_type = None, None


# Login
@bp.route('/login', methods=('GET', 'POST'))
def login():
    """Log in a registered user by adding the user id to the session."""
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        user_id = get_user(email, password)
        if user_id == -1:
            error = 'Incorrect login.'
        else:
            # Store the user id in a new session and go to index
            session.clear()
            session['user_id'] = user_id
            session['user_type'] = get_user_type(user_id)
            return redirect(url_for('user.home'))
        flash(error)
    return load_template('auth/login.html', title='Login')


# logout
@bp.route('/logout')
def logout():
    """Clear the current session, including the stored user id."""
    session.clear()
    return redirect(url_for('user.home'))


# Register
@bp.route('/register', methods=('GET', 'POST'))
def register():
    """Register a new user.

    Validates that the username is not already taken. Hashes the
    password for security.
    """
    if request.method == 'POST':
        # Defining parameters
        paramset = {'user_type', 'email', 'password', 'first_name', \
            'middle_name', 'last_name', 'birthdate', 'working_place_name', \
            'working_place_type', 'working_place_description', 'specilization', \
            'portfolio_link', 'years_experience', 'hire_date', 'working_hours', \
            'payment_rate'\
            }
        #Creating dictionary
        params = dict()
        # Getting parameters from form
        for key in paramset:
            val = request.form.get(key)
            if not val or val == '':
                val = 'NULL'
            else:
                try:
                    int(val)
                except ValueError:
                    val = "'{value}'".format(value=val)
            params[key] = val
        # Try to register the user to the database
        error = None
        user_id = register_user(params)
        if user_id == -1:
            error = 'Email already registered.'
        if not error:
            session.clear()
            session['user_id'] = user_id
            session['user_type'] = get_user_type(user_id)
            return redirect(url_for('user.home'))
        flash(error)

    return load_template('auth/register.html', title='Register')

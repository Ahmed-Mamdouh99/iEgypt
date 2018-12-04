import functools
from flask import redirect,g, session, abort, url_for
from iEgypt.model.overloaded import load_template


#Wrapper to check login
def login_required(view):
    """View decorator that redirects anonymous users to the login page."""
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if g.user is None:
            return redirect(url_for('user.login'))

        return view(**kwargs)

    return wrapped_view


# Wrapper to check account type
def account_type_required(view, type):
    """View decorator that verifies the account type."""
    @functools.wraps(view)
    def wrapped_view(**kwargs):
        if not g.user_type or g.user_type != type:
            #redirect to error page 403 unauthorized access
            abort(403)

        return view(**kwargs)

    return wrapped_view

from flask import(
    render_template, session
)


def load_template(template, **kwargs):
    """Makes sure the user state is passed to the template"""
    logged_in = False
    if session.get('user_id'):
        logged_in = True
    return render_template(template, logged_in=logged_in, **kwargs)

#

from flask import Blueprint, url_for, request
from iEgypt.model.overloaded import load_template
from iEgypt.model.auth import login_required, account_type_required


bp = Blueprint('viewer', __name__, url_prefix='/')


@bp.route('/viewer-home')
@login_required
def index():
    return load_template('coming-soon.html', title='Home')
index = account_type_required(index, 'viewer')

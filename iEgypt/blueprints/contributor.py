#TBD
from flask import (
    session, Blueprint, request
)

from iEgypt.blueprints.auth import account_type_required
from iEgypt.model.db import upload_original_content


bp = Blueprint('contributor', __name__, url_prefix='/contributor')


@bp.route('/upload-oc', methods=('GET', 'POST'))
def upload_oc():

    if request.method == 'POST':
        params = dict()
        for key, val in request.form:
            params[key] = val
        db.upload_oc(params)

    return load_template('contributor/upload-oc.html', title='Upload Original Content')

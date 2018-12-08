#TBD
from flask import session, Blueprint, request, url_for
from iEgypt.model.auth import login_required, account_type_required
from iEgypt.model.overloaded import load_template


bp = Blueprint('contributor', __name__, url_prefix='/')


@bp.route('/contributor-home')
@login_required
def index():
    return load_template('contributor/index.html', title='Home')
index = account_type_required(index, 'contributor')


@bp.route('/upload-oc', methods=('GET', 'POST'))
def upload_oc():

    if request.method == 'POST':
        params = dict()
        for key, val in request.form:
            params[key] = val
        db.upload_oc(params)

    return load_template('contributor/upload-oc.html', title='Upload Original Content')
	

@bp.route('/upload-nc', methods=('GET', 'POST'))
def upload_nc():

    if request.method == 'POST':
         params = dict()
         for key, val in request.form:
             params[key]=val
         db.upload_nc(params)
     
    return load_template('contributor/upload-nc.html', title='Upload New Content')
    
	

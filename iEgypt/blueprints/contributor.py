#TBD
from flask import Blueprint, session, request, redirect, url_for, flash, g
from iEgypt.model.overloaded import load_template
from iEgypt.model.db import contributor_model
from iEgypt.model.auth import login_required, account_type_required

#Create the blueprint
bp = Blueprint('contributor', __name__, url_prefix='/')


@bp.route('/contributor-home')
@login_required
def index():
    return load_template('contributor/index.html', title='Home')
index = account_type_required(index, 'contributor')


@bp.route('/upload-oc', methods=('GET', 'POST'))
@login_required
def upload_oc():

    if request.method == 'POST':
        params = dict()
        for key, val in request.form:
            params[key] = val
        user_id=session.get('user_id')
        contributor_model.upload_oc(params)

    return load_template('contributor/upload-oc.html', title='Upload Original Content')


@bp.route('/upload-nc', methods=('GET', 'POST'))
@login_required
def upload_nc():

    if request.method == 'POST':
         params = dict()
         for key, val in request.form:
             params[key]=val
         user_id=session.get('user_id')
         contributor_model.upload_nc(params)

    return load_template('contributor/upload-nc.html', title='Upload New Content')


@bp.route('/new-requests')
@login_required
def show_nr():
    col_names= ['id','accept status',  'specified', 'information', 'viewer id',
     'notif obj id', 'contributor_id']
    user_id=session.get('user_id')
    table=contributor_model.show_nr()

    return load_template('contributor/new-requests.html', title='New Requests',
     table=table, col_names=col_names)


@bp.route('/show-events')
@login_required
def show_events():
    col_names=['full name','id','description','location','city','time','entertainer',
    'notification object id']
    table=contributor_model.show_events()
    return load_template('contributor/show-events.html', title= 'Show Events',
     table=table, col_names=col_names)

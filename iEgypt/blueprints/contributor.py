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


@bp.route('/new-requests', methods=('GET', 'POST'))
@login_required
def show_nr():
    request_id = None
    col_names= ['id','accept status',  'specified', 'information', 'viewer id',
        'notif obj id', 'contributor id']
    user_id=session.get('user_id')
    if request.method == 'POST' and request.form.get('search'): # Filtering request
        request_id = request.form.get('request_id')
    if request.method == 'POST' and request.form.get('save'): # Confirming selections
        accepted_ids = []
        rejected_ids = []
        for key, value in request.form.items():
            if value == 'accept':
                accepted_ids.append(key)
            if value == 'reject':
                rejected_ids.append(key)
        contributor_model.respond_nr(user_id, accepted_ids, rejected_ids)
    table=contributor_model.show_nr(user_id, request_id)
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


@bp.route('/send-msg')
@login_required
def send_msg():
    return load_template('contributor/send-msg.html', title= 'Send Message')


@bp.route('/recieve-msg')
@login_required
def rec_msg():
    return load_template('contributor/rec-msg.html', title= 'Recieve Message')


@bp.route('/show-notifications')
@login_required
def show_notif():
    return load_template('contributor/show-notifications.html', title= 'Show Notifications')


@bp.route('/delete-oc')
@login_required
def delete_oc():
    return delete_oc('contributor/delete-oc.html', title= 'Delete Original Content')

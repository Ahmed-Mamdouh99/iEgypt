pip install virtualenv
virtualenv -p python3 env
source env/bin/activate
pip install -r requirements.txt
python sql.py
python runserver.py
deactivate

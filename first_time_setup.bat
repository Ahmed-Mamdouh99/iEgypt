pip install virtualenv
virtualenv -p python env
source env/bin/activate
pip install -r requirements.txt
python runserver.py
echo Process exited.
pause

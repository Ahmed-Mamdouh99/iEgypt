pip install virtualenv
virtualenv -p python env
env/bin/activate.bat
pip install -r requirements.txt
python sql.py
python runserver.py
echo Process exited.
pause

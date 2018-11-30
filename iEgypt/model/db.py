import pyodbc
from iEgypt.config import config


#Connection string for the database
connection_string = 'DRIVER={SQL Server};' +
'SERVER={server};DATABASE={database};UID={uname};PWD={passwd}'.format(
    server=config.get('db_server'),
    database=config.get('db_name'),
    uname=config.get('db_username'),
    passwd=config.get('db_password')
    )


def get_conn():
    """Return a new connection"""
    conn = pyodbc.connect(connection_string)
    return conn

def get_user(email, password): #Takes in a request object r
    """ Returns a user id or -1 """
    sql = """\
            DECLARE @user_id INTEGER;
            EXEC User_login {email}, {password}, @user_id OUT;
            SELECT @out AS output;\
        """
    sql.format(email=email, password=password)
    # Query the database
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        row = cursor.fetchone()
        try:
            return int(row[0])
        except Exception:
            return -1


def validate_profile_params(params):
    """ validates input from the registeration form"""
    # TODO - might need further validation
    try:
        if params['years_of_experience'] != 'NULL':
            int(params['years_of_experience'])
        if params['working_hours'] != 'NULL':
            int(params['working_hours'])
        if params['payment_rate'] != 'NULL':
            float(params['payment_rate'])
    except Exception:
        return 1


def register_user(params):
    #Validate data
    if validate_profile_params(params):
        return -1
    # Creating the sql query
    sql = """\
            DECLARE @user_id INTEGER = -1;
            EXEC Register_user '{usertype}', '{email}', '{password}', '{first_name}', \
            '{middle_name}', '{last_name}', '{birthdate}', '{working_place_name}', \
            '{working_place_type}', '{working_place_description}', '{specilization}', \
            '{portfolio_link}', {years_experience}, '{hire_date}', {working_hours}, \
            {payment_rate}, @user_id OUT;
            SELECT @user_id AS output;\
        """
    sql.format(**params)
    # Executing the query
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        row = cursor.fetchone()
        try:
            return int(row[0])
        except Exception:
            return -1


def user_search_og(type='NULL', cat='NULL'):
    """Return the result from proc Search_Original_Content"""
    sql = 'EXEC Original_Content_Search {type}, {category};'.format(type=type, category=cat)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.exec(sql)
        row = cursor.fetchone()
        return row

def user_search_contributor(fullname):
    """Return the result from prom Contributor_Search"""
    sql = 'EXEC Contributor_Search {fullname}'
    sql.format(fullname=fullname)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        res = []
        for row in rows:
            res += [row]
        return res

def get_user_type(user_id):
    """Returns the user type of a user in the database or None if the user is not found"""
    sql = """
        DECLARE @user_type VARCHAR(255) = '-1'
        DECLATE @user_id INTEGER = {user_id}
        IF EXISTS (SELECT * FROM [Viewer] WHERE ID=@user_id)
            SET @user_type = 'Viewer'
        ELSE IF EXISTS (SELECT * FROM [Contributor] WHERE ID=@user_id)
            SET @user_type = 'Contributor'
        ELSE IF EXISTS (SELECT * FROM [Staff] WHERE ID=@user_id)
            SET @user_type = 'Staff'
        SELECT @user_type AS output
        """
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        row = cursor.fetchone()
        type = row[0]
        if row[0] in ('Viewer', 'Contributor', 'Staff'):
            return row[0]

def edit_user(params):
    if validate_profile_params:
        return -1
    # Creating the sql query
    sql = """\
            EXEC Register_user '{usertype}', '{email}', '{password}', '{first_name}', \
            '{middle_name}', '{last_name}', '{birthdate}', '{working_place_name}', \
            '{working_place_type}', '{working_place_description}', '{specilization}', \
            '{portfolio_link}', {years_experience}, '{hire_date}', {working_hours}, \
            {payment_rate};\
        """
    sql.format(**params)
    # Executing the query
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        res = []
        for row in rows:
            res += [row]
        return res


def get_profile(user_id):
    """Returns the result of proc Show_Profile"""
    sql = """\
            DECLARE @email VARCHAR(255), @password VARCHAR(255), @first_name VARCHAR(255), \
            @middle_name VARCHAR(255), @last_name VARCHAR(255), @birth_date DATETIME, \
            @working_place_name VARCHAR(255), @working_place_type VARCHAR(255), \
            @working_place_description TEXT, @specilization  VARCHAR(255), \
            @portfolio_link  VARCHAR(255), @years_experience INTEGER, @hire_date DATETIME, \
            @working_hours INTEGER, @payment_rate REAL;
            \
            EXEC Show_Profile @{user_id}, @email OUT, @password OUT, @first_name OUT, \
            @middle_name OUT, @last_name OUT, @birth_date OUT, @working_place_name OUT, \
            @working_place_type OUT, @working_place_description OUT, @specilization OUT, \
            @portfolio_link OUT, @years_experience OUT, @hire_date OUT, @working_hours OUT, \
            @payment_rate OUT;
            \
            SELECT @email, @password, @first_name, @middle_name, @last_name, @birth_date, \
            @working_place_name, @working_place_type, @working_place_description, \
            @specilization, @portfolio_link, @years_experience, @hire_date, @working_hours, \
            payment_rate;\
        """
    sql.format(user_id=user_id)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        row = cursor.fetchone()
        return row

###################################

import pyodbc

def get_conn():
    """Return a new connection"""
    pass


def get_user(email, password): #Takes in a request object r
    """ Returns a user id or -1 """
    sql = """\
            DECLARE @user_id INTEGER;
            EXEC User_login {email}, {password}, @user_id OUT;
            SELECT @out AS the_output;\
        """
    sql.format(email=email, password=password)
    # Query the database
    with get_conn() as conn:
        conn.execute(sql)
        row = conn.fetchone()
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
            SELECT @user_id AS the_output;\
        """
    sql.format(**params)
    # Executing the query
    with get_conn() as conn:
        conn.execute(sql)
        row = conn.fetchone()
        try:
            return int(row[0])
        except Exception:
            return -1


def user_search_og(type='NULL', cat='NULL'):
    """Return the result from proc Search_Original_Content"""
    if type == 'NULL' and cat == 'NULL':
        # TODO - TBD
        pass
    sql = 'EXEC Original_Content_Search {type}, {category};'.format(type=type, category=cat)
    with get_conn() as conn:
        conn.exec(sql)
        row = conn.fetchone()
        #TODO - finish this

def user_search_contributor(name):
    # TODO - TBD
    pass

def get_user_type(user_id):
    # TODO - TBD
    pass

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
        conn.execute(sql)


def get_profile(user_id):
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
        conn.execute(sql)
        #TODO - Go on

###################################

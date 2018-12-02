from . import get_conn


def get_user(email, password):
    """ Returns a user id or -1 """
    sql = """\
            SET NOCOUNT ON
            DECLARE @user_id INTEGER = -1;
            EXEC User_login '{email}', '{password}', @user_id OUT;
            SELECT @user_id AS output;\
        """
    sql = sql.format(email=email, password=password)
    # Query the database
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    conn.close()
    try:
        return int(row[0])
    except Exception:
        return -1


def register_user(params):
    #Validate data
    #if validate_profile_params(params):
    #    return -1
    # Creating the sql query
    sql = """\
    SET NOCOUNT ON
    DECLARE @user_id INTEGER = -1;
    EXEC Register_user {user_type}, {email}, {password}, {first_name}, \
    {middle_name}, {last_name}, {birthdate}, {working_place_name}, \
    {working_place_type}, {working_place_description}, {specilization}, \
    {portfolio_link}, {years_experience}, {hire_date}, {working_hours}, \
    {payment_rate}, @user_id OUT;
    SELECT @user_id AS output;\
    """
    sql = sql.format(**params)
    # Executing the query
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    conn.close()
    try:
        return int(row[0])
    except Exception:
        return -1


def get_user_type(user_id):
    """Returns the user type of a user in the database or None if the user is not found"""
    sql = """
    SET NOCOUNT ON
    DECLARE @user_type VARCHAR(255) = '-1'
    DECLARE @user_id INTEGER = {user_id}
    IF EXISTS (SELECT * FROM [Viewer] WHERE ID=@user_id)
        SET @user_type = 'viewer'
    ELSE IF EXISTS (SELECT * FROM [Contributor] WHERE ID=@user_id)
        SET @user_type = 'contributor'
    ELSE IF EXISTS (SELECT * FROM [Staff] WHERE ID=@user_id)
        SET @user_type = 'staff'
    SELECT @user_type AS output
    """
    sql = sql.format(user_id=user_id)
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    conn.close()
    type = row[0]
    if row[0] in ('viewer', 'contributor', 'staff'):
        return row[0]


def user_edit_profile(params):
    #if validate_profile_params:
    #    return -1
    # Creating the sql query
    sql = """\
    EXEC Register_user '{usertype}', '{email}', '{password}', '{first_name}', \
    '{middle_name}', '{last_name}', '{birthdate}', '{working_place_name}', \
    '{working_place_type}', '{working_place_description}', '{specilization}', \
    '{portfolio_link}', {years_experience}, '{hire_date}', {working_hours}, \
    {payment_rate};\
    """
    sql = sql.format(**params)
    # Executing the query
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    rows = cursor.fetchall()
    conn.close()
    return rows

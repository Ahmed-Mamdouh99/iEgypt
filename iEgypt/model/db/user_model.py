from . import get_conn
import pyodbc


def validate_profile_params(params):
    """ validates input from the registeration form"""
    # TODO - might need further validation
    try:
        if params['years_of_experience'] not in ('NULL', ''):
            int(params['years_of_experience'])
        if params['working_hours']  not in ('NULL', ''):
            int(params['working_hours'])
        if params['payment_rate']  not in ('NULL', ''):
            float(params['payment_rate'])
    except Exception:
        return 1


def user_search_oc(type, cat):
    """Return the result from proc Search_Original_Content"""
    if type != 'NULL':
        type = "'"+type+"'"
    if cat != 'NULL':
        cat = "'"+cat+"'"
    sql = "EXEC Original_Content_Search {type}, {category}"
    sql = sql.format(type=type, category=cat)
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    try:
      rows = cursor.fetchall()
    except pyodbc.ProgrammingError:
      rows = []
    conn.close()
    return rows


def user_search_contributor(fullname):
    """Return the result from proc Contributor_Search"""
    sql = "EXEC Contributor_Search '{fullname}'"
    sql = sql.format(fullname=fullname)
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    try:
      rows = cursor.fetchall()
    except pyodbc.ProgrammingError:
      rows = []
    conn.close()
    return rows


def user_show_contributors():
    """Returns the result from proc Order_Contributor"""
    sql = "EXEC Order_Contributor"
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    try:
      rows = cursor.fetchall()
    except pyodbc.ProgrammingError:
      rows = []
    conn.close()
    return rows


def user_show_oc(contributor_id='NULL'):
    """Returns the result from proc Show_Original_Content"""
    sql = 'EXEC Show_Original_Content {contributor_id}'
    sql = sql.format(contributor_id=contributor_id)
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    try:
      rows = cursor.fetchall()
    except pyodbc.ProgrammingError:
      rows = []
    conn.close()
    return rows


def user_get_profile(user_id, user_type):
    """Returns the result of proc Show_Profile"""
    sql = """\
            SET NOCOUNT ON
            DECLARE @email VARCHAR(255), @password VARCHAR(255), @first_name VARCHAR(255), \
            @middle_name VARCHAR(255), @last_name VARCHAR(255), @birth_date DATETIME, \
            @working_place_name VARCHAR(255), @working_place_type VARCHAR(255), \
            @working_place_description VARCHAR(255), @specilization  VARCHAR(255), \
            @portfolio_link  VARCHAR(255), @years_experience INTEGER, @hire_date DATETIME, \
            @working_hours INTEGER, @payment_rate REAL;

            EXEC Show_Profile {user_id}, @email OUT, @password OUT, @first_name OUT, \
            @middle_name OUT, @last_name OUT, @birth_date OUT, @working_place_name OUT, \
            @working_place_type OUT, @working_place_description OUT, @specilization OUT, \
            @portfolio_link OUT, @years_experience OUT, @hire_date OUT, @working_hours OUT, \
            @payment_rate OUT;

            SELECT @email, @password, @first_name, @middle_name, @last_name, @birth_date, \
            @working_place_name, @working_place_type, @working_place_description, \
            @specilization, @portfolio_link, @years_experience, @hire_date, @working_hours, \
            @payment_rate;\
        """
    sql = sql.format(user_id=user_id)
    conn = get_conn()
    cursor = conn.cursor()
    cursor.execute(sql)
    row = cursor.fetchone()
    conn.close()
    col_names = ['Email', 'Password', 'First name', 'Middle name', 'Last name',
         'Birthday', 'Working place name', 'Working place type',
         'Working place description', 'Specialization', 'Portfolio link',
         'Years of experience', 'Hire date', 'Working hours', 'Payment rate']
    labels = dict()
    for i in range(len(row)):
        labels[col_names[i]] = row[i]
    viewer_labels = ('Working place name', 'Working place type', \
     'Working place type')
    contributor_labels = ('Specialization', 'Portfolio link', \
     'Years of experience')
    staff_labels = ('Hire date', 'Working hours', 'Payment rate')
    if user_type == 'viewer':
        for label in staff_labels+contributor_labels:
            labels.pop(label, None)
    elif user_type == 'Contributor':
        for label in viewer_labels+staff_labels:
            labels.pop(label, None)
    else:
        for label in viewer_labels+contributor_labels:
            labels.pop(label, None)
    return labels

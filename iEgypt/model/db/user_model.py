from . import get_conn


"""SQL Procedures"""


def get_user_type(id):
    sql = """\
    SET NOCOUNT ON
    DECLARE @type VARCHAR(255), @id INTEGER;
    SET @id={id}
    IF EXISTS (SELECT * FROM [viewer] WHERE id=@id)
        SET @type='viewer';
    ELSE IF EXISTS (SELECT * FROM [contributor] WHERE id=@id)
        SET @type='contributor';
    ELSE IF EXISTS (SELECT * FROM [content manager] WHERE id=@id)
        SET @type='content manager';
    ELSE IF EXISTS (SELECT * FROM [reviewer] WHERE id=@id)
        SET @type='reviewer';
    SELECT @type AS out;
    """
    sql = sql.format(id=id)
    with get_conn() as conn:
        return conn.cursor().execute(sql).fetchone()[0]


def search_oc(type, category):
    condition = ''
    if type or category:
        condition = "WHERE "
        if type:
            condition += "type='{type}' AND ".format(type=type)
        if category:
            condition += "category='{category}'".format(category=category)
    sql = """\
    SELECT c.id, [contributor id], [category type], type, link, rating
    FROM [original content] oc JOIN [Content] c ON c.id=oc.id
    """
    sql += condition
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result


def contributor_search(name=None):
    condition = ''
    if name:
        conditon = " AND ([first name]+' '+[middle name]+' '+[last name]) like \
        '%{}%' OR ([first name]+' '+[last name]) like '%{}%'".format(name, name)
    sql = """\
    SELECT u.id, ([first name]+' '+[middle name]+' '+[last name]) AS 'full name',\
     age, [years of experience], [portfolio link], specialization
    FROM [user] u JOIN [contributor] c ON u.id=c.id
    WHERE u.active=1
    """
    sql += condition
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result


def register(**user_data):
    #keys = (key for key, _ in user_data.items())
    #for key in keys:
    #    user_data[key] = user_data[key].lower()
    # Check if the email exists
    sql = "SELECT * FROM [user] WHERE email='{email}'".format(**user_data)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        if cursor.fetchone():
            return -1
    # Register user
    sql = """\
    SET NOCOUNT ON
    INSERT INTO [user] (email, password, [first name], [middle name], [last name], \
    birthday) VALUES ('{email}', '{password}', '{first name}', '{middle name}', \
     '{last name}', '{birthday}');
    DECLARE @id INTEGER;
    SELECT @id=MAX(id) FROM [user];
    """
    if user_data['type'] == 'viewer':
        sql += """\
        INSERT INTO [{type}] (id) VALUES (@id);
        SELECT @id as OUT;
        """
    else:
        sql += """\
        INSERT INTO [notified person] (id) VALUES (@id);
        INSERT INTO [{type}] (id, [notified id]) VALUES (@id, @id);
        SELECT @id AS out;
        """
    sql = sql.format(**user_data)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        result = int(cursor.fetchone()[0])
        return result


def check_type(user_id, type):
    # Check if the type exists
    sql = "SELECT * FROM [content type] WHERE type='{}'".format(type)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        try:
            cursor.fetchone()
        except Exception:
            raise Exception
    # Perform task
    sql = "UPDATE [content manager] SET type='{}' WHERE id={}".format(type, id)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)


def order_contributor():
    sql = """\
    SELECT u.id, ([first name]+' '+[middle name]+' '+[last name]) AS \
    'full name', age, [years of experience], specialization, [portfolio link]
    FROM [contributor] c JOIN [user] u ON c.id=u.id
    WHERE u.active=1
    ORDER BY [years of experience] DESC;
    """
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result


def show_original_content(id=None):
    sql = """\
    SELECT ct.id AS 'content id', [category type], [subcategory name], YEAR([uploaded at]) AS\
     'year', rating, ([first name]+' '+[middle name]+' '+[last name]) AS \
    'full name', email, birthday, age, [years of experience], [portfolio link],\
    specialization
    FROM [user] u JOIN [contributor] cr ON u.id=cr.id
                  JOIN [content] ct ON ct.[contributor id]=cr.id
                  JOIN [original content] oc ON oc.id = ct.id
    WHERE [filter status]=1
    """
    if id:
        sql += " AND cr.id={}".format(id)
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result


def login(email, password):
    sql = """\
    SET NOCOUNT ON
    DECLARE @id INTEGER=NULL;
    SELECT @id=id
    FROM [user]
    WHERE email='{email}' AND password='{password}' AND (active=1 OR
    datediff(WEEK, CURRENT_TIMESTAMP, [last login]) <= 2)
    IF @id IS NOT NULL BEGIN
      UPDATE [user] SET [last login]=CURRENT_TIMESTAMP, active=1 WHERE id=@id;
      SELECT @id;
    END
    ELSE IF EXISTS (SELECT * FROM [user] WHERE id=@id) BEGIN
      SET @id=-1;
      SELECT @id;
    END
    """
    sql = sql.format(email=email, password=password)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)
        try:
            result = int(cursor.fetchone()[0])
            return result
        except Exception:
            pass


def show_profile(user_id, user_type):
    sql = """\
    SELECT email, [first name], [middle name], [last name], password, birthday, \
    """
    if user_type == 'viewer':
        sql += "[working place], [working place type], \
        [working place description]"
    elif user_type == 'contributor':
        sql += "specialization, [portfolio link], [years of experience]"
    else:
        user_type = 'Staff'
        sql += " [hire date], [working hours], [payment rate]"
    sql += """
    FROM [user] u JOIN [{user_type}] a ON u.id=a.id
    WHERE u.id={user_id}\
    """.format(user_type=user_type, user_id=user_id)
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result[0]


def deactivate_profile(user_id):
    sql = "UPDATE [user] SET active=0 WHERE id={id}".format(id=user_id)
    with get_conn() as conn:
        conn.cursor().execute(sql)


def edit_profile(user_id, user_type, user_data, other_data):
    sql = ''
    if len(user_data) > 0:
        sql = 'UPDATE [user] SET'
        for col, val in user_data.items():
            if val != '':
                flag = True
                sql += " [{col}]='{val}',".format(col=col, val=val)
        sql = sql[0:-1] + " WHERE id={id}".format(id=user_id)

    if user_type in ('reviewer', 'content manager'):
        user_type = 'staff'
    if len(other_data) > 0:
        sql += "\nUPDATE [{user_type}] SET".format(user_type=user_type)
        for col, val in other_data.items():
            sql += " [{col}]='{val}',".format(col=col, val=val)
        sql = sql[0:-1] + " WHERE id={id}".format(id=user_id)
    with get_conn() as conn:
        conn.cursor().execute(sql)


def show_event(id=None):
    sql = """\
    SELECT ([first name]+' '+[middle name]+' '+[last name]) AS 'full name', \
    e.id, description, location, city, time, entertainer
    FROM [event] e JOIN [user] u ON e.[viewer id]=u.id
    WHERE time > CURRENT_TIMESTAMP\
    """
    if id:
        sql += " AND e.id={id}".format(id=id)
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        columns = [column[0] for column in cursor.description]
        result = []
        for row in cursor.fetchall():
            result.append(dict(zip(columns, row)))
        return result


def get_user_name(id):
    sql = "SELECT [first name] FROM [user] WHERE id={id}".format(id=id)
    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        result = cursor.fetchone()[0]
        return result

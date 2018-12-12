from . import get_conn

def upload_oc(id,params):

    #Validate data
    sql = "SELECT * FROM [subcategory] WHERE name = {subcategory name}".format(**params)


    sql= """\
    -- Create new entry for content
    INSERT INTO "content" ([uploaded at], [contributor id], [category type], [subcategory name], type, link)
    VALUES (CURRENT_TIMESTAMP, {id}, '{category type}', '{subcategory name}', '{type id}', '{link}');
    -- Get the id of the new content
    DECLARE @content_id INTEGER = (SELECT max(id) FROM content)
    -- Create new entry for original content
    INSERT INTO [original content] (id) VALUES (@content_id);
    """

    sql=sql.format(id=id, **params)
    with get_conn() as conn:
      cursor = conn.cursor()
      cursor.execute(sql)


def upload_nc(id,params):

    sql="""\
     -- Create entry in content
    INSERT INTO "content" ([uploaded at], [contributor id], [category type], [subcategory name], type, link)
    VALUES (CURRENT_TIMESTAMP, {id}, '{category type}', '{subcategory name}', '{type id}', '{link}');
    -- Get the id of the new content
    DECLARE @content_id INTEGER = (SELECT max(ID) FROM content)
    -- Create entry in new content
    INSERT INTO [new content] (id, new request id) VALUES (@content_id, @new_request_id);
    """

    sql=sql.format(id=id, **params)
    with get_conn() as conn:
        cursor = conn.cursor()
        cursor.execute(sql)


def show_nr(request_id, contributor_id):
    sql="""\
    SELECT * []
    FROM [new request]
    WHERE ([contributor id] = {contributor_id} OR specified = 0)\
  """

  if request_id:
      sql += 'AND id={request_id}'.format(request_id=request_id)
  sql.format(contributor_id=contributor_id)

    


def show_events(id=None):
    sql="""\
    SELECT ([first name]+''+[middle name]+''+[last name]) AS 'full name', e.id,
 e.description, e.location, e.city, e.time, e.entertainer,e.[notification object id]
        FROM [event] e
               INNER JOIN [user] u ON e.[viewer id] = u.id
        WHERE e.time > CURRENT_TIMESTAMP
    """

    if id:
        sql += ' AND e.id={id}'.format(id=id)

    with get_conn() as conn:
        cursor = conn.cursor().execute(sql)
        try:
            columns = [column[0] for column in cursor.description]
            result = []
            for row in cursor.fetchall():
                result.append(dict(zip(columns,row)))
            return result
        except Exception:
            return None

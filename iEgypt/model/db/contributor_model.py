from . import get_conn

def upload_oc(id,params):

    #Validate data
    sql = "SELECT * FROM [subcategory] WHERE name = {subcategory name}".format(**params)
    

    sql= """\
    -- Create new entry for content
    INSERT INTO "Content" ([uploaded at], [contributor id], [category type], [subcategory name], type, link)
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

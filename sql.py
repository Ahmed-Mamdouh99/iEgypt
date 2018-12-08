import pyodbc


def get_conn():
  conn = pyodbc.connect(driver='{SQL Server}', Trusted_Connection='yes', server='DESKTOP-KNPB2R3\SQLEXPRESS', autocommit=True, database='IEgypt_78')
  return conn

  
sql = '''
  SELECT * FROM [user];
'''

with get_conn() as conn:
  cursor = conn.cursor()
  cursor.execute(sql)
  rows = cursor.fetchall()
  for row in rows:
      print(row)
input()

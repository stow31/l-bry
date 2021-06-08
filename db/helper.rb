require 'pg'
require 'sinatra'

def run_sql(sql, params = [])
    db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'l_bry'})
    res = db.exec(sql, params)
    db.close
    return res
end
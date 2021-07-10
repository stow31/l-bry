require 'bcrypt'

def get_all_users()
    sql = "SELECT * FROM users;"
    run_sql(sql)
end

def create_user(email, password, first_name, last_name)

    password_digest = BCrypt::Password.create(password)

    sql = "INSERT INTO users (email, password_digest, first_name, last_name) VALUES ($1, $2, $3, $4)"

    run_sql(sql, [email, password_digest, first_name, last_name])

end

def get_user_by_email(email)
    sql_get_id = "SELECT * FROM users WHERE email = $1;"

    run_sql(sql_get_id, [email])
end

def get_user_by_id(user_id)
    sql = "SELECT * FROM users WHERE id = $1"
    run_sql(sql, [user_id])
end

def update_password(user_id, password)
    password_digest = BCrypt::Password.create(user_new_password)

    sql = "UPDATE users SET password_digest = $1 WHERE id = $2"

    run_sql(sql, [password_digest, user_id])
end

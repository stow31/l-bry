require 'bcrypt'
require_relative "helper.rb"

# CREATE USER START

email = "se.townsend31@gmail.com"
password = "pudding"
first_name = "Sophie"
last_name = "Townsend"

password_digest = BCrypt::Password.create(password)

# Remember anything you pass in here will automatically converted to a string 
sql = "INSERT INTO users (email, password_digest, first_name, last_name) VALUES ('#{email}', '#{password_digest}', '#{first_name}', '#{last_name}');"

# run_sql(sql)

# CREATE USER END
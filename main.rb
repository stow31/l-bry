require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'bcrypt'
require 'httparty'
require 'pry' if development?
require_relative "db/helper.rb"

enable :sessions

# METHODS

def current_user
  if session[:user_id] == nil
    return {}
  else 
    run_sql("SELECT * FROM users WHERE id = #{session[:user_id]};")[0]
  end
end

def logged_in?
  if session[:user_id] == nil
    return false
  end
  return true
end

def book_search(search_book)
  url = "https://www.googleapis.com/books/v1/volumes?q=#{search_book}&printType=books&orderBy=relevance&maxResults=40&key=#{ENV['GOOGLEBOOKS_API_KEY']}"
  return HTTParty.get(url)
end

def one_book(id)
  url = "https://www.googleapis.com/books/v1/volumes/#{id}?key=#{ENV['GOOGLEBOOKS_API_KEY']
  }"
  return HTTParty.get(url)
end

def club_details(club_id)
  sql = "SELECT * FROM clubs where id = #{club_id}"
  return run_sql(sql)[0]
end

def list_user_clubs(user_id)
  sql_current_clubs = "SELECT * FROM users WHERE id = #{user_id}"
  user_records = run_sql(sql_current_clubs)
  return user_records[0]["clubs"]
end

def admin?(club_id)
  user_id = current_user["id"]

  if user_id == club_details(club_id)["admin_user_id"]
    return true
  end
  return false
end

# HTTP METHODS

get '/' do
  erb :index
end

# search results page
get '/books/search' do
  search_book = params["search_books"]
  res = book_search(search_book)
  # binding.pry
  erb :search, locals:{
    books: res["items"]
  }
end

# individual book detail page & add the book clicked to the DB
get '/books/details/:id' do

  res = one_book(params["id"])
  
  title = res["volumeInfo"]["title"]
  cover_image = res["volumeInfo"]["imageLinks"]["thumbnail"]
  author = res["volumeInfo"]["authors"]&.join
  rating = res["volumeInfo"]["averageRating"]
  genre = res["volumeInfo"]["categories"]&.join&.gsub(" /", ",")
  bio = res["volumeInfo"]["description"]
  book_id = params["id"]
  
  if logged_in?
    sql = "SELECT * FROM books_users WHERE user_id = #{current_user["id"]} AND book_id = '#{book_id}';"
    records = run_sql(sql)
  end

  erb :book_details, locals:{
    title: title,
    cover_image: cover_image,
    author: author,
    rating: rating,
    genre: genre,
    bio: bio,
    book_id: book_id,
    records: records
  }
end

# about page
get '/books/about' do
  erb :about
end

# login page
get '/books/login' do
  if logged_in?
    redirect '/'
  else
    erb :login
  end
end

# setting up login action 
post '/books/session' do
  sql = "SELECT * FROM users WHERE email = '#{params["email"]}'"
  records = run_sql(sql)

  if records.count>0 && BCrypt::Password.new(records[0]['password_digest']) == params["password"]
    logged_in_user = records[0]
    session[:user_id] = logged_in_user["id"]
    redirect '/'
  else
    erb :login
  end
 
end

# set up log out action 
delete '/books/session' do
  session[:user_id] = nil
  redirect '/'
end

# sign up page 
get '/books/signup' do
  if logged_in?
    redirect '/'
  else
    erb :sign_up
  end
end

# set up the new account action
post '/books/new_session' do
  email = params["email"]
  password = params["password"]
  first_name = params["first_name"]
  last_name = params["last_name"]

  sql_check = "SELECT * FROM users WHERE email = '#{email}';"
  records = run_sql(sql_check)

  if records.count == 0

    password_digest = BCrypt::Password.create(password)

    sql_insert = "INSERT INTO users (email, password_digest, first_name, last_name) VALUES ('#{email}', '#{password_digest}', '#{first_name}', '#{last_name}');"

    run_sql(sql_insert)

    sql_get_id = "SELECT * FROM users WHERE email = '#{email}';"

    logged_in_result = run_sql(sql_get_id)
    logged_in_user = logged_in_result[0]
    session[:user_id] = logged_in_user["id"]

    redirect '/'
  else
    erb :login
  end
 
end

# add book to your want to read list if logged in 
# NOTE I AM USING THE book_id FOR THE JOIN HERE 
post '/books/want/:id' do
  book_id = params["id"]

  sql_insert = "INSERT INTO books_users (book_id, user_id, book_status) VALUES ( '#{book_id}', #{session[:user_id]}, 'want');"

  run_sql(sql_insert)

  redirect '/books/want'
end

# my account page 
get '/books/myaccount' do
  if logged_in?
    sql = "SELECT * FROM users WHERE id = #{session[:user_id]};"
    records = run_sql(sql)
    
    erb :my_account, locals:{
      users: current_user
    }
  else 
    redirect '/books/login'
  end
end

# want to read page 
get '/books/want' do 
  user_id = current_user["id"]

  sql = "SELECT * FROM books_users WHERE user_id = #{user_id} AND book_status = 'want';"

  records = run_sql(sql)
  erb :want_to_read, locals: {
    want_list: records
  }
end

# move book to currently reading status
put '/books/current/:id' do 
  user_id = current_user["id"]
  book_id = params["id"]
  
  sql = "UPDATE books_users SET book_status = 'current' WHERE user_id = #{user_id} AND book_id = '#{book_id}';"

  run_sql(sql)

  redirect '/books/current'
end

# currently reading page
get '/books/current' do 
  user_id = current_user["id"]

  sql = "SELECT * FROM books_users WHERE user_id = #{user_id} AND book_status = 'current';"

  records = run_sql(sql)
  erb :current_read, locals: {
    current_list: records
  }
end

#move book to finished reading status
put '/books/finished/:id' do 
  user_id = current_user["id"]
  book_id = params["book_id"]
  
  sql = "UPDATE books_users SET book_status = 'read' WHERE user_id = #{user_id} AND book_id = '#{book_id}';"

  run_sql(sql)

  redirect '/books/finished'
end

# finished reading page
get '/books/finished' do 
  user_id = current_user["id"]

  sql = "SELECT * FROM books_users WHERE user_id = #{user_id} AND book_status = 'read';"

  records = run_sql(sql)
  erb :finished_read, locals: {
    finished_list: records
  }
end

# delete book from your want to or currently reading list
delete '/books/:id' do
  user_id = current_user["id"]
  book_id = params["id"]

  sql = "DELETE FROM books_users WHERE user_id = #{user_id} AND book_id = '#{book_id}';"

  run_sql(sql)

  redirect request.referrer
  
end

# clubs main page with list of clubs and create clubs input 
get '/books/clubs' do

  if logged_in?
    user_id = current_user["id"]

    sql = "SELECT * FROM users WHERE id = #{user_id};"
    records = run_sql(sql)
    clubs_arr = records[0]["clubs"]&.split(",")
    
  erb :club_list, locals: {
    clubs: clubs_arr
  }

  else
    redirect '/books/login'
  end

end

# create new club, add to clubs db and add to users list
post '/books/club/new' do
  club_name = params["club_name"]
  user_id = current_user["id"]

  # inserting the club into clubs table
  sql_insert_club = "INSERT INTO clubs(club_name, admin_user_id) VALUES ($1, $2);"
  run_sql(sql_insert_club, [club_name, user_id])

  # getting the new clubs id
  sql_club_id = "SELECT * FROM clubs WHERE club_name = '#{club_name}';"
  club_records = run_sql(sql_club_id);
  new_club_id = club_records [0]["id"]

  # getting the current clubs the user is in
  user_current_clubs = list_user_clubs(user_id)

  # ammending the current list to add the new club
  if user_current_clubs
    sql_update_user_clubs = "UPDATE users SET clubs = CONCAT('#{user_current_clubs}', ',#{new_club_id}') WHERE id = #{user_id}; "
  else
    sql_update_user_clubs = "UPDATE users SET clubs = '#{new_club_id}' WHERE id = #{user_id}; "
  end

  run_sql(sql_update_user_clubs)

  redirect request.referrer
end

# delete book clubs from the db
delete '/books/club/delete/:id' do
  club_id = params["id"]
  user_id = current_user["id"]

  # getting the current users clubs
  user_current_clubs = list_user_clubs(user_id).split(",")

  # finding and removing the club that is being deleted
  if user_current_clubs.count >1
    club_index = user_current_clubs.index("#{club_id}")
    user_current_clubs.delete_at(club_index)
    user_updated_clubs = user_current_clubs.join(",")

    sql_update = "UPDATE users SET clubs = '#{user_updated_clubs}' WHERE id = #{user_id};"

    run_sql(sql_update)
  else
    sql_update = "UPDATE users SET clubs = NULL  WHERE id = #{user_id};"

    run_sql(sql_update)
  end

  # deleting the club from the clubs table 
  sql_delete_club = "DELETE FROM clubs WHERE id = #{club_id};"
  run_sql(sql_delete_club)

  redirect request.referrer

end

# club details page
get '/books/club_details/:id' do
  club_id = params["id"]
  
  erb :club_details, locals:{
    club: club_details(club_id)
  }
end

post '/books/club/new_member/:id' do
  club_id = params["id"]
  email = params["email"]

  sql_check_email = "SELECT * FROM users WHERE email = $1"
  user_record = run_sql(sql_check_email, [email])
  binding.pry
  
  if user_record.count>0
    club_list = list_user_clubs(user_record["id"])
    # ammending the current list to add the new club
    if club_list #if club list is nil or not
      sql_update_user_clubs = "UPDATE users SET clubs = CONCAT('#{club_list}', ',#{club_id}') WHERE id = #{user_record["id"]}; "
    else
      sql_update_user_clubs = "UPDATE users SET clubs = '#{club_id}' WHERE id = #{user_record["id"]}; "
    end
  end

  redirect request.referrer
end




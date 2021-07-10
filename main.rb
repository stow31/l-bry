require 'sinatra'
require 'sinatra/reloader' if development?
require 'pg'
require 'bcrypt'
require 'httparty'
require 'pry' if development?

enable :sessions

require_relative "db/helper.rb"

# models
require_relative "models/users.rb"
require_relative "models/clubs.rb"
require_relative "models/clubs_users.rb"
require_relative "models/books_clubs.rb"
require_relative "models/books_users.rb"

# controllers

# helper

# METHODS

def check_bookclub_list
  p "checking"
end

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

def list_user_clubs(user_id)
  user_records = get_user_by_id(user_id)
  # update here
  return user_records[0]["clubs"]
end

def admin?(club_id)
  user_id = current_user["id"]

  if user_id == get_club_details_with_id(club_id)["admin_user_id"]
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
  erb :search, locals:{
    books: res["items"]
  }
end

# individual book detail page
get '/books/details/:id' do

  res = one_book(params["id"])
  user_id = current_user["id"]
  
  title = res["volumeInfo"]["title"]
  cover_image = res["volumeInfo"]["imageLinks"]["thumbnail"]
  author = res["volumeInfo"]["authors"]&.join(" ")
  rating = res["volumeInfo"]["averageRating"]
  genre = res["volumeInfo"]["categories"]&.join&.gsub(" /", ",")
  bio = res["volumeInfo"]["description"]
  book_id = params["id"]
  
  if logged_in?
    records = get_users_book_list(user_id, book_id)

    # A list of clubs the user is a part of
    club_list = get_club_list(user_id)
    book_recs_by_club = books_in_clubs(user_id, book_id)
  end

  erb :book_details, locals:{
    title: title,
    cover_image: cover_image,
    author: author,
    rating: rating,
    genre: genre,
    bio: bio,
    book_id: book_id,
    records: records,
    club_list: club_list,
    book_recs_by_club: book_recs_by_club
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

  records = get_user_by_email(params["email"])

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

  records = get_user_by_email(email)

  if records.count == 0
    create_user(email, password, first_name, last_name)
    logged_in_result = get_user_by_email(email)
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

    records = get_user_by_id(session[:user_id])
    
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
  book_id = params["id"]
  
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
get '/books/club' do
  if logged_in?
    user_id = current_user["id"]
    club_list = get_club_list(user_id)

    erb :club_list, locals: {
    club_list: club_list
  }
  else
    redirect '/books/login'
  end

end

# create new club, add to clubs db and add to users list
put '/books/club/new' do
  club_name = params["club_name"]
  user_id = current_user["id"]

  create_club(club_name, user_id)

  club_records = get_club_details_with_name(club_name)
  new_club_id = club_records [0]["id"]
  assign_user_to_club(user_id, new_club_id)

  redirect request.referrer
end

# delete book clubs from the db
delete '/books/club/delete/:id' do
  club_id = params["id"]
  user_id = current_user["id"]

  delete_club(club_id)

  delete_club_from_all_users(club_id)

  redirect request.referrer

end

# club details page
get '/books/club_details/:id' do
  club_id = params["id"]

  want_list = books_in_club(club_id, "want")
  current_list = books_in_club(club_id, "current")
  read_list = books_in_club(club_id, "read")


  erb :club_details, locals:{
    club: get_club_details_with_id(club_id),
    want_list: want_list,
    current_list: current_list,
    read_list: read_list
  }
end

# add an existing user of your app to your book club
put '/books/club/new_member/:id' do
  club_id = params["id"]
  email = params["email"]

  user_record = get_user_by_email(email)

  if user_record.count>0

    assign_user_to_club(user_record[0]["id"], club_id)

  end
  # TODO Alert when the user doens't exist ?

  redirect request.referrer
end

# delete books from the book club list 
delete '/books/club/:club_id/:book_id' do
  club_id = params["club_id"]
  book_id = params["book_id"]

  sql = "DELETE FROM books_clubs WHERE club_id = $1 AND book_id = $2;"
  run_sql(sql, [club_id, book_id])

  redirect request.referrer
end

# move books in your book club from want to read to currently reading 
put '/books/club/current/:club_id/:book_id' do
  club_id = params["club_id"]
  book_id = params["book_id"]

  sql = "UPDATE books_clubs SET book_status = 'current' WHERE club_id = $1 AND book_id = $2;"
  run_sql(sql, [club_id, book_id])

  redirect request.referrer
end

# move books in your book club from currently reading to read
put '/books/club/finished/:club_id/:book_id' do
  club_id = params["club_id"]
  book_id = params["book_id"]

  sql = "UPDATE books_clubs SET book_status = 'read' WHERE club_id = $1 AND book_id = $2;"
  run_sql(sql, [club_id, book_id])

  redirect request.referrer
end

# add books to want to read list
post '/books/club/add/:club_id/:book_id' do 
  club_id = params["club_id"]
  book_id = params["book_id"]

  sql = "INSERT INTO books_clubs(book_id, club_id, book_status) VALUES ($1, $2, 'want');"

  run_sql(sql, [book_id, club_id])

  redirect request.referrer

end 

get '/books/club/help' do 
  erb :clubs_help
end

get '/books/password' do
  if logged_in?
    erb :new_password
  else
    redirect '/books/signup'
  end
end

put '/books/new-password' do

  user_id = current_user["id"]
  user_new_password = params["password"]

  update_password(user_id, user_new_password)

  redirect '/books/myaccount'
end

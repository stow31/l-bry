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
  url = "https://www.googleapis.com/books/v1/volumes/#{id}"
  return HTTParty.get(url)
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

# individual book detail page & add the book clicked to the DB
get '/books/details/:id' do
  res = one_book(params["id"])
  
  title = res["volumeInfo"]["title"]
  cover_image = res["volumeInfo"]["imageLinks"]["small"]
  author = res["volumeInfo"]["authors"].join
  rating = res["volumeInfo"]["averageRating"]
  genre = res["volumeInfo"]["categories"]
  # .join.gsub(" /", ",")
  bio = res["volumeInfo"]["description"]
  google_id = params["id"]

  sql = "INSERT INTO books (title, author, cover_image, rating, genre, bio, google_id) VALUES ($1, $2, $3, $4, $5, $6, $7);"

  run_sql(sql, [
    title,
    author,
    cover_image,
    rating,
    genre,
    bio,
    google_id
    ])

  erb :book_details, locals:{
    title: title,
    cover_image: cover_image,
    author: author,
    rating: rating,
    genre: genre,
    bio: bio,
    google_id: google_id
  }
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
# NOTE I AM USING THE GOOGLE_ID FOR THE JOIN HERE 
post '/books/want/:id' do
  google_id = params["id"]

  sql_insert = "INSERT INTO books_users (book_id, user_id, book_status) VALUES ( '#{google_id}', #{session[:user_id]}, 'want');"

  run_sql(sql_insert)

  redirect '/'
end



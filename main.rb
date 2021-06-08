require 'sinatra'
require 'sinatra/reloader' if development?
require 'PG'
require 'bcrypt'
require 'pry'
require 'httparty'

def book_search(search_book)
  url = "https://www.googleapis.com/books/v1/volumes?q=#{search_book}&printType=books&orderBy=relevance&maxResults=40&key=AIzaSyCxxWfkDPthw1l8Ir6FqDVL--yZfOl0jTw"
  return HTTParty.get(url)
end

def one_book(id)
  url = "https://www.googleapis.com/books/v1/volumes/#{id}"
  return HTTParty.get(url)
end

def run_sql(sql, params = [])
  db = PG.connect(ENV['DATABASE_URL'] || {dbname: 'l_bry'})
  res = db.exec(sql, params)
  db.close
  return res
end

get '/' do
  erb :index
end

get '/books/search' do
  search_book = params["search_books"]
  res = book_search(search_book)

  erb :search, locals:{
    books: res["items"]
  }
end

get '/books/new/:id' do
  res = one_book(params["id"])
  
  title = res["volumeInfo"]["title"]
  cover_image = res["volumeInfo"]["imageLinks"]["smallThumbnail"]
  author = res["volumeInfo"]["authors"].join
  rating = res["volumeInfo"]["averageRating"].floor
  genre = res["volumeInfo"]["categories"].join.gsub(" /", ",")
  bio = res["volumeInfo"]["description"]

  sql = "INSERT INTO books (title, author, cover_image, rating, genre, bio) VALUES ($1, $2, $3, $4, $5, $6);"

  run_sql(sql, [
    title,
    author,
    cover_image,
    rating,
    genre,
    bio
    ])

  redirect '/'
  end

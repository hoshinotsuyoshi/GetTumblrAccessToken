# coding: utf-8
require 'sinatra'
require 'net/http'
require 'haml'
require 'sass'
require 'tumblr_wrapper'

use Rack::Session::Pool, :expire_after => 2592000 # instead of "enable :sessions" to encrypt

CALLBACK_URL = 'http://gettumblraccesstoken.heroku.com/callback'

get '/style.css' do
  sass :stylesheet
end

get '/' do
  haml :page_form
end

post '/' do
  TumblrWrapper.consumer_key = params[:consumer_key]
  TumblrWrapper.consumer_secret = params[:consumer_secret]
  client = TumblrWrapper::Client.new

  session["consumer_key"] = TumblrWrapper.consumer_key
  session["consumer_secret"] = TumblrWrapper.consumer_secret
  authorize_url = client.authorize_url
  session["request_token"] = client.request_token.token
  session["request_token_secret"] = client.request_token.secret

  redirect authorize_url
end

get '/callback' do
  oauth_verifier = params[:oauth_verifier]

  #request_token = session["request_token"]
  TumblrWrapper.consumer_key = session["consumer_key"]
  TumblrWrapper.consumer_secret = session["consumer_secret"]
  client = TumblrWrapper::Client.new
  client.build_request_token(session["request_token"], session["request_token_secret"])
  access_token = client.request_access_token(oauth_verifier)

  @consumer_key        = access_token[:consumer_key]
  @consumer_secret     = access_token[:consumer_secret]
  @access_token        = access_token[:token]
  @access_token_secret = access_token[:token_secret]

  haml :page_result
end


not_found do
  "NOT FOUND!"
end

error do
  "ERROR!"
end

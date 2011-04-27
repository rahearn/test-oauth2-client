require 'sinatra'
require 'oauth2'
require 'json'

def client
  OAuth2::Client.new('4db87a8a77d1eaa566000001', '56b257762db953aa4a1b36cfd16d3b1d33bb5005cc51f272f1c817f694ff7cff', :site => 'http://localhost:3000/')
end

get '/' do
  'working'
end

get '/auth' do
  redirect client.web_server.authorize_url(
    :redirect_uri => redirect_uri
  )
end

get '/access' do
  access_token = client.password.get_access_token(params[:username], params[:password])
  user = JSON.parse(access_token.get('/current_user.json'))
  user.inspect
end

get '/auth/callback' do
  access_token = client.web_server.get_access_token(params[:code], :redirect_uri => redirect_uri)
  user = JSON.parse(access_token.get('/current_user.json'))
  user.inspect
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end

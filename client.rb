require 'sinatra'
require 'oauth2'
require 'json'
require 'haml'

set :haml, :format => :html5

def client
  # app id, app secret, and site are all test-env specific
  OAuth2::Client.new('4db87a8a77d1eaa566000001', '56b257762db953aa4a1b36cfd16d3b1d33bb5005cc51f272f1c817f694ff7cff', :site => 'http://localhost:3000/')
end

get '/' do
  @header = 'Log In'
  haml :session
end

get '/logout' do
  response.set_cookie 'access_token', ''
  @header = 'Logged Out'
  haml :session
end

get '/auth' do
  redirect client.web_server.authorize_url(
    :redirect_uri => redirect_uri
  )
end

get '/auth/callback' do
  access_token = client.web_server.get_access_token params[:code], :redirect_uri => redirect_uri
  @user = JSON.parse access_token.get('/current_user.json')
  haml :user
end

get '/access' do
  access_token = client.password.get_access_token params[:username], params[:password]
  response.set_cookie 'access_token', access_token.token
  @user = JSON.parse access_token.get('/current_user.json')
  haml :user
end

get '/businesses' do
  access_token = OAuth2::AccessToken.new client, request.cookies['access_token']
  @businesses = JSON.parse access_token.get('/businesses.json')
  haml :businesses
end

post '/business' do
  access_token = OAuth2::AccessToken.new client, request.cookies['access_token']
  @business = JSON.parse access_token.post('/businesses.json', :business => {:name => params[:name], :address => {:street1 => params[:street], :city => params[:city], :state => params[:state], :zip => params[:zip]}, :phone_number => params[:phone_number], :description => 'created by sinatra app'})
  haml :new_business
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end

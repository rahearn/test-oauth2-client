require 'sinatra'
require 'oauth2'
require 'json'
require 'haml'

set :haml, :format => :html5

def client
  # app id, app secret, and site are all test-env specific
  OAuth2::Client.new('3696e1467b8af7bf8a0a27c02a45c711cd308cb6', 'd3b51712962a45bc5ba9ff9ad5460271ac70afba', :site => 'http://localhost:3000/')
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
  response.set_cookie 'access_token', {:value => access_token.token, :path => '/'}
  @user = JSON.parse access_token.get('/current_user.json')
  haml :user
end

get '/access' do
  access_token = client.password.get_access_token params[:username], params[:password]
  response.set_cookie 'access_token', {:value => access_token.token, :path => '/'}
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

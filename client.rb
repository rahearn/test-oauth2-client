require 'sinatra'
require 'rack/oauth2'
require 'json'
require 'haml'

set :haml, :format => :html5

def client
  # app id, app secret, and site are all test-env specific
  Rack::OAuth2::Client.new(
    :identifier   => '0c80181f5120de2451b551f4fe71a57b7f49ffb9',
    :secret       => '297d62ed72ee80d10fc900e0d88839482da57d1b',
    :redirect_uri => redirect_uri,
    :scheme       => 'http',
    :host         => 'localhost',
    :port         => 3000,
    :token_endpoint => '/oauth/access_token'
  )
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

# get '/auth' do
#   redirect client.web_server.authorize_url(
#     :redirect_uri => redirect_uri
#   )
# end

# get '/auth/callback' do
#   access_token = client.web_server.get_access_token params[:code], :redirect_uri => redirect_uri
#   user = JSON.parse access_token.get('/current_user.json')
#   user.inspect
# end

get '/access' do
  c = client
  c.resource_owner_credentials = params[:username], params[:password]
  access_token = c.access_token!
  #response.set_cookie 'access_token', access_token.token
  user = JSON.parse access_token.get('http://localhost:3000/current_user.json')
  user.inspect
end

# get '/businesses' do
#   access_token = OAuth2::AccessToken.new client, request.cookies['access_token']
#   @businesses = JSON.parse access_token.get('/businesses.json')
#   haml :businesses
# end

# post '/business' do
#   access_token = OAuth2::AccessToken.new client, request.cookies['access_token']
#   @business = JSON.parse access_token.post('/businesses.json', :business => {:name => params[:name], :address => {:street1 => params[:street], :city => params[:city], :state => params[:state], :zip => params[:zip]}, :phone_number => params[:phone_number], :description => 'created by sinatra app'})
#   haml :new_business
# end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end

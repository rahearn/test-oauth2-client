require 'sinatra'
require 'rack/oauth2'
require 'json'

def client
  # app id, app secret, and site are all test-env specific
  Rack::OAuth2::Client.new(
    :identifier   => '3696e1467b8af7bf8a0a27c02a45c711cd308cb6',
    :secret       => 'd3b51712962a45bc5ba9ff9ad5460271ac70afba',
    :redirect_uri => redirect_uri,
    :scheme       => 'http',
    :host         => 'localhost',
    :port         => 3000,
    :token_endpoint => '/oauth/access_token'
  )
end

get '/' do
  'working'
end

get '/logout' do
  response.set_cookie 'access_token', ''
  'logged out'
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

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/auth/callback'
  uri.query = nil
  uri.to_s
end

require 'sinatra/base'
require 'sinatra/cookies'

class Responder < Sinatra::Base
  helpers Sinatra::Cookies

  set :protection, false

  get '/200' do
    status 200
    headers 'Server' => 'Teapot Server'
    'OK'
  end

  get '/200/headers' do
    status 200
    cookies[:cookie1] = 'JohnDoe'
    cookies[:cookie2] = 'JaneRoe'
    headers 'Server' => 'Teapot Server',
            'Connection' => 'Keep-Alive',
            'Via' => '1.0 fred',
            'Vary' => 'Cookie',
            'X-Powered-By' => 'PHP/5.1.2+LOL'
    'OK'
    # "Transfer-encoding" => "chunked",
  end

  get '/418' do
    status 418
    headers 'Allow'  => 'POST, GET, HEAD, PUT, DELETE, CONNECT',
            'Server' => 'Teapot Server'
    body "I'm a tea pot!"
  end

  get '/500' do
    status 500
    headers 'Server' => 'Teapot Server',
            'Connection' => 'close'
    true
  end
end

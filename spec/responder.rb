require 'sinatra'

class Responder < Sinatra::Base

  set :protection, false

  get '/418' do
    status 418
    headers "Allow"  => "POST, GET, HEAD, PUT, DELETE, CONNECT",
            "Server" => "Teapot Server"
    body "I'm a tea pot!"
  end

  get '/500' do
    status 500
    headers "Server" => "Teapot Server",
            "Connection" => "close"
    true
  end

end

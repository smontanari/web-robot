require 'sinatra/base'
require 'logger'

module WebRobot
  class App < Sinatra::Base
    get '/' do
      send_file 'views/index.html'
    end
  end
end

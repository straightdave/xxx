require 'sinatra'
require 'sinatra/json'
require 'json'
require 'tilt/erb'
require 'active_record'
require_relative 'models/init'
require_relative 'controllers/init'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => "localhost",
  :username => "dave",
  :password => "123123",
  :database => "xxx"
)

# let sinatra use correct timezone to save data
ActiveRecord::Base.default_timezone = :local

# avoid db connection deadlock issue
after do
  ActiveRecord::Base.connection.close
end

# set public folder
set :public_folder, File.dirname(__FILE__) + '/public'

enable :sessions

#set :show_exceptions, false
error do
  "just got fucked!"
end

get "/404" do
  "This is homepage"
end

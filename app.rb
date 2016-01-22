require 'sinatra'
require 'tilt/erb'
require 'sinatra/json'
require 'sinatra/cookies'
require 'sinatra/content_for'
require 'active_record'
require 'json'
require 'cgi'
require 'redis'
require 'visual_captcha_cn'
require_relative 'models/init'
require_relative 'controllers/init'
require_relative 'helpers/init'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => "localhost",
  :username => "dave",
  :password => "123123",
  :database => "xxx"
)

# let sinatra use correct timezone to save data
ActiveRecord::Base.default_timezone = :local

before do
  @session = VisualCaptchaCN::Session.new session
  @headers = { 'Access-Control-Allow-Origin' => '*' }
end

# avoid db connection deadlock issue
after do
  ActiveRecord::Base.connection.close
  headers @headers
end

# other config
configure do
  # redis conf for delayed mailing jobs
  set :redis_conf, { host: '127.0.0.1',
                     port: 6379,
                     mailer_list: 'validation',
                     db: 8 }
  set :site_host, 'http://localhost:4567'
  set :public_folder, File.dirname(__FILE__) + '/public'
  use Rack::Session::Pool, expire_after: 60 * 60 * 2, http_only: true
end

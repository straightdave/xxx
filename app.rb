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
require 'ruby_identicon'
require_relative 'models/init'
require_relative 'controllers/init'
require_relative 'helpers/init'

configure do
  set :db_conf, {
    :host     => "localhost",
    :username => "dave",
    :password => "123123",
    :database => "xxx"
  }

  set :redis_conf, {
    :host       => '127.0.0.1',
    :port       => 6379,
    :db         => 8,
    :mail_queue => 'validation'
  }

  enable  :ignore_repu_limit
  enable  :mail_validation
  enable  :ignore_status_limit
  disable :ignore_roles_limit

  set :quoted_char_num, 140

  set :public_folder, File.dirname(__FILE__) + '/public'
  set :avatar_folder, File.dirname(__FILE__) + '/public/uploads/avatars'
  set :editorimage_folder, File.dirname(__FILE__) + '/public/uploads/editorimages'
  use Rack::Session::Pool, expire_after: 60 * 60 * 2, http_only: true

  log_file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  log_file.sync = true
  use Rack::CommonLogger, log_file
end

configure :production do
  set :db_conf, {
    :host     => "localhost",
    :username => "root",
    :password => "123123",
    :database => "xxx"
  }

  disable :ignore_repu_limit
  enable  :mail_validation
  disable :ignore_status_limit
  disable :ignore_roles_limit
end

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql2",
  :host     => settings.db_conf[:host],
  :username => settings.db_conf[:username],
  :password => settings.db_conf[:password],
  :database => settings.db_conf[:database]
)

# let sinatra use correct timezone to save data
ActiveRecord::Base.default_timezone = :local

before do
  $Scheme_host_port = "#{request.scheme}://#{request.host_with_port}"
  if login?
    unless @_current_user
      @_current_user = User.find_by(id: session[:user_id])
    end
  end
end

# avoid db connection refused issue
after do
  ActiveRecord::Base.connection.close
end

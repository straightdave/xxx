require_relative "home"
require_relative "account_manage"
require_relative "log"
require_relative "job_manage"

before '/admin/*' do
  login_filter required_roles: [ User::Role::ADMIN ]
end

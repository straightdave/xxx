class UserLogin < ActiveRecord::Base
  self.table_name = 'user_login'
  self.primary_key = 'user_id'
end

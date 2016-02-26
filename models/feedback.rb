class Feedback < ActiveRecord::Base
  # == associations ==
  belongs_to :author, class_name: "User", foreign_key: "user_id"
end

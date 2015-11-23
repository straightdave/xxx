class Vote < ActiveRecord::Base

  # == associations ==
  belongs_to :votable, polymorphic: true
  belongs_to :voter, class_name: "User", foreign_key: "user_id"

end

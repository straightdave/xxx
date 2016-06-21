class Vote < ActiveRecord::Base
  belongs_to :votable, polymorphic: true
  belongs_to :voter, class_name: "User", foreign_key: "user_id"
  belongs_to :votee, class_name: "User", foreign_key: "votee_id"
end

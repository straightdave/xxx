class Feedback < ActiveRecord::Base
  # == associations ==
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # == validation ==
  validates :title, :description, presence: true
  validates :title, length: { maximum: 100, too_long: "标题请勿超过100字符" }
  validates :description, length: { maximum: 500, too_long: "问题请勿超过500字符" }
end

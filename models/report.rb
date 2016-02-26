class Report < ActiveRecord::Base
  # == associations ==
  belongs_to :reportable, polymorphic: true
  belongs_to :reporter, class_name: "User", foreign_key: "user_id"

  # == validations ==
  validates :content, length: { maximum: 500, too_long: "内容请勿超过500字符" }
end

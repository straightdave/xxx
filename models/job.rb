class Job < ActiveRecord::Base
  # == post privilege ==
  NORMAL  = 0
  TOPPED  = 1
  EXPIRED = 2

  # == associations ==
  has_and_belongs_to_many :tags, -> { uniq },
                          join_table: "job_tag",
                          class_name: "Tag",
                          foreign_key: "job_id",
                          association_foreign_key: "tag_id"

end

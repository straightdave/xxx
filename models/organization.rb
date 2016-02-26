class Organization < ActiveRecord::Base
  # == associations ==
  has_and_belongs_to_many :users, -> { uniq },
                          join_table: "user_organization",
                          class_name: "User",
                          foreign_key: "organization_id",
                          association_foreign_key: "user_id"

end

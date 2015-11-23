class Comment < ActiveRecord::Base

  # == associations ==
  has_many :votes, as: :votable
  belongs_to :commentable, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # == helpers ==
  def scores
    (votes && !votes.empty?) ? (votes.inject {|sum, v| sum += v.point}) : 0
  end

end

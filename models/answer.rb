class Answer < ActiveRecord::Base

  # == associations ==
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

  # == helpers ==
  def scores
    (votes && !votes.empty?) ? (votes.inject {|sum, v| sum += v.point}) : 0
  end

end

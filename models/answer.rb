class Answer < ActiveRecord::Base

  # == associations ==
  has_many :comments, as: :commentable
  has_many :votes, as: :votable
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question

  # == helpers ==
  def scores
    @scores = 0
    votes.each {|v| @scores += v.points} if votes && !votes.empty?
    @scores
  end

  def scores=(new_val)
    @score = new_val
  end

end

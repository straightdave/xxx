# provide mixins for all votable objects
module Votability
  def scores
    return @t_score unless @t_score.nil?

    @t_scores = 0
    votes.each { |v| @t_scores += v.points } if votes && !votes.empty?
    @t_scores
  end

  def scores=(new_val)
    @t_score = new_val
  end
end

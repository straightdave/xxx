helpers do

  def just_viewed_this?(qid)
    !cookies[:just_viewed].split(':')
                          .index(qid.to_s)
                          .nil?
  end

  def set_just_viewed(qid)
    cookies[:just_viewed] << "#{qid}:"
  end

  def already_voted?(obj)
    user_id = session[:user_id]
    obj.votes.any? {|v| v.user_id == user_id}
  end


end

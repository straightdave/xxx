helpers do
  def just_viewed_this?(qid)
    return false unless cookies[:just_viewed]
    !cookies[:just_viewed].split(':')
                          .index(qid.to_s)
                          .nil?
  end

  def set_just_viewed(qid)
    if cookies[:just_viewed]
      cookies[:just_viewed] += "#{qid}:"
    else
      cookies[:just_viewed] = "#{qid}:"
    end
  end

  def already_voted?(obj)
    user_id = session[:user_id]
    obj.votes.any? { |v| v.user_id == user_id }
  end

  def get_abstract(content, num_of_char)
    res = content.gsub(%r{</?[^>]+?>}, '')
    if res.size <= num_of_char
      res
    else
      res[0 .. num_of_char]
    end
  end
end

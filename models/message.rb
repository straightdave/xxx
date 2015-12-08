class Message < ActiveRecord::Base
  # == helpers ==
  def sender
    User.find_by(id: from_uid)
  end

  def unread_size
    Message.where(isread: false).size
  end
end

require 'digest'

helpers do
  def login?
    session[:user] != nil
  end

  def salty_hash(passwd, salt)
    Digest::MD5.hexdigest(passwd << salt)
  end
end

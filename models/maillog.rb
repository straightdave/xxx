class MailLog < ActiveRecord::Base
  module STATUS
    PREPARE = 0
    SENDING = 1
    DOSENT  = 2
    ERROR   = 3
  end

  module TYPE
    USER_CONFIRM       = 0
    PASSWORD_RETRIEVE  = 1
  end

  self.table_name = 'mail_logs'
end

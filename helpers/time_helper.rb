helpers do
  def time_ago_in_words_zh(time)
    return unless time
    diff = Time.now - time

    case
    when diff / 60 < 1 then "1分钟以内"
    when (mins = diff / 60) < 60 then "#{mins.to_i}分钟之前"
    when (hours = diff / 3600) < 24 then "#{hours.to_i}小时之前"
    when (days = diff / 86400) < 30 then "#{days.to_i}天之前"
    else "#{time.year}年#{time.mon}月#{time.day}日 #{time.hour}时#{time.min}分"
    end
  end
end

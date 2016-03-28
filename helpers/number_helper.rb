helpers do
  
  def get_format_number(number)
    case
    when number >= 1000 && number <= 999999
      pri = number / 1000
      sub = (number / 100) % 10
      sub > 0 ? "#{pri}.#{sub}K" : "#{pri}K"
    when number > 999999
      pri = number / 1000000
      sub = (number / 100000) % 10
      sub > 0 ? "#{pri}.#{sub}M" : "#{pri}M"
    else
      number.to_s
    end
  end

end

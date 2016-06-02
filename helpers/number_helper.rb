helpers do
  # used in views
  # hundred => Xk
  # hundred thousand => Xm
  # one digit reserved
  def get_format_number(input_number)
    number = input_number.abs
    is_neg = (input_number < 0)

    result = case
    when number >= 100 && number < 100000
      pri = number / 1000
      sub = (number / 100) % 10
      sub > 0 ? "#{pri}.#{sub}k" : "#{pri}k"
    when number > 100000
      pri = number / 1000000
      sub = (number / 100000) % 10
      sub > 0 ? "#{pri}.#{sub}m" : "#{pri}m"
    else
      number.to_s
    end

    if is_neg
      "<span class='number-neg'>-#{result}</span>"
    else
      result
    end
  end
end

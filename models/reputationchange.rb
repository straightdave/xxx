class ReputationChange < ActiveRecord::Base
  self.table_name = "repu_change_logs"

  belongs_to :user

  # == helpers ==
  def self.get_top_user_by(period, top_n = 10)
    period_clause = case period
    when :today
      # from TODAY 00:00 ~ now
      "CURDATE()"
    when :week
      # from this Monday 00:00 ~ now
      "SUBDATE(CURDATE(),WEEKDAY(CURDATE()))"
    when :month
      # from 1st day of this Month, its 00:00 ~ now
      "DATE_ADD(DATE_ADD(LAST_DAY(CURDATE()),interval 1 DAY),interval -1 MONTH)"
    when :season
      # this season?
      "DATE_ADD(DATE_ADD(LAST_DAY(CURDATE()),interval 1 DAY),
      interval (3 * ( (MONTH(CURDATE()) - 1) div 3 ) - MONTH(CURDATE())) MONTH)"
    when :year
      # from 1st day of this year
      "MAKEDATE(year(now()),1)"
    end

    ReputationChange.find_by_sql("
      SELECT a.user_id, c.login_name, a.repu_sum, b.nickname, b.avatar FROM
      (
        SELECT user_id, sum(value) AS repu_sum
        FROM repu_change_logs
        WHERE created_at > #{period_clause}
        GROUP BY user_id
        LIMIT #{top_n}
      ) AS a
      LEFT JOIN user_info AS b ON a.user_id = b.user_id
      LEFT JOIN users AS c ON a.user_id = c.id
      ORDER BY a.repu_sum DESC;");
  end

  def self.get_today_sum_for_user(user_id)
    ReputationChange
      .where("user_id = :user_id AND created_at > CURDATE()", {user_id: user_id})
      .sum("value")
  end
end

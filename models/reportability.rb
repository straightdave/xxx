module Reportability
  def is_reported?
    self.has_reports > 0
  end
end

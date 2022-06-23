module ApplicationHelper
  def number_of_days_since(date)
    (Date.current - date.to_date).to_i
  end
end

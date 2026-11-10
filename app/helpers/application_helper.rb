module ApplicationHelper
  def number_of_days_since(date)
    (Date.current - date.to_date).to_i
  end

  def current_page_aria(current)
    if current
      { aria: { current: "page" } }
    else
      {}
    end
  end
end

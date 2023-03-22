class Cigarette < ApplicationRecord
  validates :quantity, presence: true
  validates :date, presence: true

  def self.last_cigarette
    order(:date).last
  end

  def self.periods
    cigarettes_orders_by_date = order(:date)
    last_index =  cigarettes_orders_by_date.length - 1
    periods = [current_period]
    for i in 1..last_index
      periods << {
        start_date: cigarettes_orders_by_date[i - 1].date_format,
        end_date: cigarettes_orders_by_date[i].date_format,
        days: (cigarettes_orders_by_date[i].date_format - cigarettes_orders_by_date[i - 1].date_format).to_i
      }
    end
    periods.sort_by{ |period| period.dig(:days) }.reverse
  end

  def date_format
    date.to_date
  end

  def self.current_period
    {
      start_date: last_cigarette.date_format,
      end_date: Date.current,
      days: (Date.current - last_cigarette.date_format).to_i,
      current: true
    }
  end
end

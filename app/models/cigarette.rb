class Cigarette < ApplicationRecord
  validates :quantity, presence: true
  validates :date, presence: true

  def self.last_cigarette
    order(:date).last
  end
end

# first tank has to be a full tank
class Tank < ApplicationRecord
  validates :volume, presence: true
  validates :price, presence: true

  def self.list_for_details
    all.where(full: true).order(distance: :desc)
  end

  def self.list_for_all
    all.order(distance: :desc)
  end

  def full_tank?
    full
  end

  def price_per_liter
    (price / volume).round(2)
  end

  def previous_full_tank
    list_all_as_array = self.class.order(:distance).to_a
    self_index = list_all_as_array.index(self)

    return self if self_index.zero?
    var_index = self_index - 1
    previous_tank = list_all_as_array[var_index]

    until list_all_as_array[var_index].full_tank?
      var_index -= 1
      previous_tank = list_all_as_array[var_index]
    end
    previous_tank
  end

  def calculated_distance_delta
    return nil unless full_tank?

    distance - previous_full_tank.distance
  end

  def calculated_volume
    return nil unless full_tank?

    list_all_as_array = self.class.order(:distance).to_a
    self_index = list_all_as_array.index(self)
    return volume if self_index.zero?

    previous_full_tank_index = list_all_as_array.index(previous_full_tank)
    list_all_as_array[previous_full_tank_index + 1..self_index].sum(&:volume)
  end

  def consumption
    return "-" if calculated_distance_delta.nil?
    return "-" if calculated_distance_delta.zero?

    (calculated_volume * 100 / calculated_distance_delta).round(2)
  end

  def days_since_previous_tanks
    return "-" if date.blank? || previous_full_tank&.date.blank?

    (date.to_date - previous_full_tank.date.to_date).to_i
  end
end

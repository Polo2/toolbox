require "rails_helper"

RSpec.describe Tank, type: :model do
  describe "validations" do
    it "requires a volume" do
      tank = Tank.new(date: Date.new(2021, 6, 1), distance: 1_000, price: 60, full: true)

      expect(tank).not_to be_valid
      expect(tank.errors.of_kind?(:volume, :blank)).to be(true)
    end

    it "requires a price" do
      tank = Tank.new(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, full: true)

      expect(tank).not_to be_valid
      expect(tank.errors.of_kind?(:price, :blank)).to be(true)
    end
  end

  describe ".list_for_all" do
    it "orders every reading by mileage descending" do
      low_mileage = 1_000
      high_mileage = 1_800
      low = Tank.create!(date: Date.new(2021, 6, 1), distance: low_mileage, volume: 40, price: 60, full: true)
      high = Tank.create!(date: Date.new(2021, 6, 5), distance: high_mileage, volume: 10, price: 15, full: false)

      expect(Tank.list_for_all).to eq([high, low])
    end
  end

  describe ".list_for_details" do
    it "orders full tanks by mileage descending" do
      low_mileage = 1_000
      high_mileage = 1_800
      low = Tank.create!(date: Date.new(2021, 6, 1), distance: low_mileage, volume: 40, price: 60, full: true)
      high = Tank.create!(date: Date.new(2021, 6, 11), distance: high_mileage, volume: 30, price: 45, full: true)

      expect(Tank.list_for_details).to eq([high, low])
    end

    it "leaves out partial fills" do
      full = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      Tank.create!(date: Date.new(2021, 6, 5), distance: 1_400, volume: 10, price: 15, full: false)

      expect(Tank.list_for_details).to eq([full])
    end
  end

  describe "#price_per_liter" do
    it "divides the amount paid by the volume" do
      price = 10
      volume = 3
      price_per_liter = 3.33
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume:, price:, full: true)

      expect(tank.price_per_liter).to eq(price_per_liter)
    end
  end

  describe "#calculated_distance_delta" do
    it "is zero for the first full tank" do
      distance = 1_000
      distance_since_previous_full_tank = 0
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance:, volume: 40, price: 60, full: true)

      expect(tank.calculated_distance_delta).to eq(distance_since_previous_full_tank)
    end

    it "is nil for a partial fill" do
      tank = Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: 10, price: 15, full: false)

      expect(tank.calculated_distance_delta).to be_nil
    end

    it "counts the mileage since the previous full tank" do
      previous_full_distance = 1_000
      distance = 1_500
      distance_since_previous_full_tank = 500
      Tank.create!(date: Date.new(2021, 6, 1), distance: previous_full_distance, volume: 40, price: 60, full: true)
      tank = Tank.create!(date: Date.new(2021, 6, 11), distance:, volume: 30, price: 45, full: true)

      expect(tank.calculated_distance_delta).to eq(distance_since_previous_full_tank)
    end
  end

  describe "#calculated_volume" do
    it "is the tank volume for the first full tank" do
      volume = 40
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume:, price: 60, full: true)

      expect(tank.calculated_volume).to eq(volume)
    end

    it "is nil for a partial fill" do
      tank = Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: 10, price: 15, full: false)

      expect(tank.calculated_volume).to be_nil
    end

    it "adds partial fills to the next full tank" do
      partial_volume = 10
      full_volume = 30
      volume_since_previous_full_tank = 40
      Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: partial_volume, price: 15, full: false)
      tank = Tank.create!(date: Date.new(2021, 6, 11), distance: 1_500, volume: full_volume, price: 45, full: true)

      expect(tank.calculated_volume).to eq(volume_since_previous_full_tank)
    end
  end

  describe "#consumption" do
    it "is a dash for the first full tank" do
      no_consumption = "-"
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      expect(tank.consumption).to eq(no_consumption)
    end

    it "is a dash for a partial fill" do
      no_consumption = "-"
      tank = Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: 10, price: 15, full: false)

      expect(tank.consumption).to eq(no_consumption)
    end

    it "reports liters per 100 km since the previous full tank" do
      partial_volume = 10
      full_volume = 30
      liters_per_100_km = 8.0
      Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: partial_volume, price: 15, full: false)
      tank = Tank.create!(date: Date.new(2021, 6, 11), distance: 1_500, volume: full_volume, price: 45, full: true)

      expect(tank.consumption).to eq(liters_per_100_km)
    end
  end

  describe "#days_since_previous_tanks" do
    it "is zero when the reading is the first full tank" do
      days_since_previous_full_tank = 0
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      expect(tank.days_since_previous_tanks).to eq(days_since_previous_full_tank)
    end

    it "counts the days since the previous full tank" do
      days_since_previous_full_tank = 4
      Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      tank = Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: 10, price: 15, full: false)

      expect(tank.days_since_previous_tanks).to eq(days_since_previous_full_tank)
    end

    it "is a dash when the reading has no date" do
      no_elapsed_days = "-"
      tank = Tank.create!(date: nil, distance: 1_000, volume: 40, price: 60, full: true)

      expect(tank.days_since_previous_tanks).to eq(no_elapsed_days)
    end
  end
end

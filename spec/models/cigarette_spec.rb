require "rails_helper"

RSpec.describe Cigarette, type: :model do
  describe "validations" do
    it "requires a quantity" do
      cigarette = Cigarette.new(date: Date.new(2024, 1, 1))

      expect(cigarette).not_to be_valid
      expect(cigarette.errors.of_kind?(:quantity, :blank)).to be(true)
    end

    it "requires a date" do
      cigarette = Cigarette.new(quantity: 1)

      expect(cigarette).not_to be_valid
      expect(cigarette.errors.of_kind?(:date, :blank)).to be(true)
    end
  end

  describe ".last_cigarette" do
    it "returns the cigarette with the latest date" do
      january = Date.new(2024, 1, 1)
      february = Date.new(2024, 2, 1)
      march = Date.new(2024, 3, 1)
      Cigarette.create!(quantity: 1, date: january)
      latest = Cigarette.create!(quantity: 2, date: march)
      Cigarette.create!(quantity: 1, date: february)

      expect(Cigarette.last_cigarette).to eq(latest)
    end
  end

  describe ".periods" do
    it "lists the open stretch and the gaps between cigarettes, longest first" do
      travel_to Date.new(2024, 2, 1) do
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 1))
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 21))
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 26))
        expected_periods = [
          {
            start_date: Date.new(2024, 1, 1),
            end_date: Date.new(2024, 1, 21),
            days: 20
          },
          {
            start_date: Date.new(2024, 1, 26),
            end_date: Date.new(2024, 2, 1),
            days: 6,
            current: true
          },
          {
            start_date: Date.new(2024, 1, 21),
            end_date: Date.new(2024, 1, 26),
            days: 5
          }
        ]

        expect(Cigarette.periods).to eq(expected_periods)
      end
    end

    it "returns only the stretch since that cigarette when it is the only one" do
      travel_to Date.new(2024, 1, 11) do
        Cigarette.create!(quantity: 3, date: Date.new(2024, 1, 1))
        expected_periods = [
          {
            start_date: Date.new(2024, 1, 1),
            end_date: Date.new(2024, 1, 11),
            days: 10,
            current: true
          }
        ]

        expect(Cigarette.periods).to eq(expected_periods)
      end
    end
  end
end

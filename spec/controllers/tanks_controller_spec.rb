require "rails_helper"

RSpec.describe TanksController, type: :controller do
  render_views

  describe "GET #index" do
    it "lists the mileage of every reading" do
      full_tank_distance = 150_904
      partial_fill_distance = 151_200
      Tank.create!(date: Date.new(2021, 6, 13), distance: full_tank_distance, volume: 50, price: 70, full: true)
      Tank.create!(date: Date.new(2021, 6, 20), distance: partial_fill_distance, volume: 12, price: 20, full: false)

      get :index

      expect(response.body).to include("<td>#{full_tank_distance}</td>")
      expect(response.body).to include("<td>#{partial_fill_distance}</td>")
    end

    it "marks a full tank as oui and a partial fill as non" do
      Tank.create!(date: Date.new(2021, 6, 13), distance: 150_904, volume: 50, price: 70, full: true)
      Tank.create!(date: Date.new(2021, 6, 20), distance: 151_200, volume: 12, price: 20, full: false)

      get :index

      expect(response.body).to include("<td>oui</td>")
      expect(response.body).to include("<td>non</td>")
    end

    it "shows the site header with Kangoo as the current page" do
      get :index

      expect(response.body).to include("<header")
      expect(response.body).to include(%(href="#{root_path}">Accueil))
      expect(response.body).to include(%(aria-current="page" href="#{tanks_path}">Kangoo))
      expect(response.body).to include(%(href="#{cigarettes_path}">Cigarettes))
    end
  end

  describe "GET #details" do
    it "shows liters per 100 km for a full tank" do
      partial_volume = 10
      full_volume = 30
      liters_per_100_km = "8.0"
      Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      Tank.create!(date: Date.new(2021, 6, 5), distance: 1_200, volume: partial_volume, price: 15, full: false)
      Tank.create!(date: Date.new(2021, 6, 11), distance: 1_500, volume: full_volume, price: 45, full: true)

      get :details

      expect(response.body).to include("<td>#{liters_per_100_km}</td>")
    end

    it "leaves out partial fills" do
      partial_fill_distance = 1_111
      Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)
      Tank.create!(date: Date.new(2021, 6, 5), distance: partial_fill_distance, volume: 10, price: 15, full: false)

      get :details

      expect(response.body).not_to include("<td>#{partial_fill_distance}</td>")
    end
  end

  describe "GET #show" do
    it "shows the mileage and the date of the reading" do
      distance = 1_000
      formatted_date = "01/06/2021"
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance:, volume: 40, price: 60, full: true)

      get :show, params: { id: tank.id }

      expect(response.body).to include("#{distance} km")
      expect(response.body).to include(formatted_date)
    end

    it "raises when the reading does not exist" do
      unknown_tank_id = 0

      expect {
        get :show, params: { id: unknown_tank_id }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #new" do
    it "renders the form" do
      get :new

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nouveau relevé de carburant")
    end
  end

  describe "POST #create" do
    it "stores the submitted reading" do
      distance = 1_000
      volume = 40
      price = 60

      expect {
        post :create, params: {
          tank: { date: "2021-06-13", distance:, volume:, price:, full: true }
        }
      }.to change(Tank, :count).by(1)

      stored = Tank.find_by!(distance:)
      expect(stored.volume).to eq(volume)
      expect(stored.price).to eq(price)
      expect(stored.full).to be(true)
    end

    it "redirects to the stored reading" do
      distance = 1_000

      post :create, params: {
        tank: { date: "2021-06-13", distance:, volume: 40, price: 60, full: true }
      }

      expect(response).to redirect_to(tank_path(Tank.find_by!(distance:)))
      expect(flash[:notice]).to eq("Nouveau relevé ajouté.")
    end

    it "renders the form again when the volume is missing" do
      expect {
        post :create, params: {
          tank: { date: "2021-06-13", distance: 1_000, price: 60, full: true }
        }
      }.not_to change(Tank, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Nouveau relevé de carburant")
    end
  end

  describe "GET #edit" do
    it "renders the edit form" do
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      get :edit, params: { id: tank.id }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Modifier relevé")
    end
  end

  describe "PATCH #update" do
    it "stores the submitted mileage" do
      original_distance = 1_000
      submitted_distance = 2_000
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: original_distance, volume: 40, price: 60, full: true)

      patch :update, params: {
        id: tank.id,
        tank: { date: "2021-06-01", distance: submitted_distance, volume: 40, price: 60, full: true }
      }

      expect(tank.reload.distance).to eq(submitted_distance)
    end

    it "redirects to the list" do
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      patch :update, params: {
        id: tank.id,
        tank: { date: "2021-06-01", distance: 2_000, volume: 40, price: 60, full: true }
      }

      expect(response).to redirect_to(tanks_path)
      expect(flash[:notice]).to eq("Relevé mis à jour.")
    end

    it "keeps the mileage when the volume is missing" do
      original_distance = 1_000
      submitted_distance = 9_999
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: original_distance, volume: 40, price: 60, full: true)

      patch :update, params: {
        id: tank.id,
        tank: { date: "2021-06-01", distance: submitted_distance, volume: "", price: 60, full: true }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(tank.reload.distance).to eq(original_distance)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the reading" do
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      expect {
        delete :destroy, params: { id: tank.id }
      }.to change(Tank, :count).by(-1)
    end

    it "redirects to the list" do
      tank = Tank.create!(date: Date.new(2021, 6, 1), distance: 1_000, volume: 40, price: 60, full: true)

      delete :destroy, params: { id: tank.id }

      expect(response).to redirect_to(tanks_path)
      expect(flash[:notice]).to eq("Tank was successfully destroyed.")
    end
  end
end

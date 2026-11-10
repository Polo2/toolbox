require "rails_helper"

RSpec.describe CigarettesController, type: :controller do
  render_views

  describe "GET #index" do
    it "renders when no cigarette has been recorded" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Pas encore de cigarette enregistrée")
      expect(response.body).to include(%(aria-current="page" href="#{cigarettes_path}">Cigarettes))
    end

    it "shows how many days have passed since the last cigarette" do
      travel_to Date.new(2024, 2, 1) do
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 26))
        days_since_last_cigarette = 6

        get :index

        expect(response.body).to include(%(<h5 class="card-title primary">#{days_since_last_cigarette}</h5>))
      end
    end

    it "lists the smoke-free stretches, longest first" do
      travel_to Date.new(2024, 2, 1) do
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 1))
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 21))
        Cigarette.create!(quantity: 1, date: Date.new(2024, 1, 26))
        longest_stretch_in_days = 20
        open_stretch_in_days = 6
        shortest_stretch_in_days = 5

        get :index

        longest_stretch = response.body.index("<td>#{longest_stretch_in_days}</td>")
        open_stretch = response.body.index("<td>#{open_stretch_in_days}</td>")
        shortest_stretch = response.body.index("<td>#{shortest_stretch_in_days}</td>")

        expect(longest_stretch).to be < open_stretch
        expect(open_stretch).to be < shortest_stretch
      end
    end
  end

  describe "GET #new" do
    it "renders the form" do
      get :new

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nouvelle(s) cigarette(s)")
    end

    it "shows the site header with Cigarettes as the current page" do
      get :new

      expect(response.body).to include("<header")
      expect(response.body).to include("Permacouture")
      expect(response.body).to include(%(href="#{root_path}">Accueil))
      expect(response.body).to include(%(href="#{tanks_path}">Kangoo))
      expect(response.body).to include(%(aria-current="page" href="#{cigarettes_path}">Cigarettes))
    end
  end

  describe "POST #create" do
    it "stores the submitted quantity and date" do
      quantity = 2
      smoked_on = Date.new(2024, 1, 11)

      expect {
        post :create, params: { cigarette: { quantity:, date: smoked_on.to_s } }
      }.to change(Cigarette, :count).by(1)

      stored = Cigarette.find_by!(quantity:)
      expect(stored.date.to_date).to eq(smoked_on)
    end

    it "redirects to the list" do
      post :create, params: { cigarette: { quantity: 2, date: "2024-01-11" } }

      expect(response).to redirect_to(cigarettes_path)
      expect(flash[:notice]).to eq("nouvelle clope ajoutée... Dommage 😢")
    end

    it "renders the form again when the date is missing" do
      expect {
        post :create, params: { cigarette: { quantity: 2 } }
      }.not_to change(Cigarette, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Nouvelle(s) cigarette(s)")
    end
  end
end

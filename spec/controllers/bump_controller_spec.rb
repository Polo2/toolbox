require "rails_helper"

RSpec.describe BumpController, type: :controller do
  render_views

  describe "GET #ping" do
    it "renders the ping page" do
      get :ping

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ping this webhook")
    end

    it "shows the site header without marking a tool as the current page" do
      get :ping

      expect(response.body).to include("<header")
      expect(response.body).to include(%(href="#{root_path}">Accueil))
      expect(response.body).to include(%(href="#{tanks_path}">Kangoo))
      expect(response.body).to include(%(href="#{cigarettes_path}">Cigarettes))
      expect(response.body).not_to include('aria-current="page"')
    end
  end
end

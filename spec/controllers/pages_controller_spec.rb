require "rails_helper"

RSpec.describe PagesController, type: :controller do
  render_views

  describe "GET #home" do
    it "offers the Kangoo readings" do
      get :home

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Kangoo roule", tanks_path)
    end

    it "offers the cigarettes tool" do
      get :home

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cigarettes", cigarettes_path)
    end

    it "shows the site header with Accueil as the current page" do
      get :home

      expect(response.body).to include("<header")
      expect(response.body).to include("Permacouture")
      expect(response.body).to include(%(aria-current="page" href="#{root_path}">Accueil))
      expect(response.body).to include(%(href="#{tanks_path}">Kangoo))
      expect(response.body).to include(%(href="#{cigarettes_path}">Cigarettes))
    end
  end
end

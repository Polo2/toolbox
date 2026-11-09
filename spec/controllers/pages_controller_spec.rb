require "rails_helper"

RSpec.describe PagesController, type: :controller do
  render_views

  describe "GET #home" do
    it "offers the Kangoo readings" do
      get :home

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Kangoo roule", tanks_path)
    end
  end
end

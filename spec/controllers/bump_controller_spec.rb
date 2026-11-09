require "rails_helper"

RSpec.describe BumpController, type: :controller do
  render_views

  describe "GET #ping" do
    it "renders the ping page" do
      get :ping

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ping this webhook")
    end
  end
end

class CigarettesController < ApplicationController
  before_action :set_cigarette, only: %i[ show  destroy ]

  # GET /cigarettes or /cigarettes.json
  def index
    @cigarettes = Cigarette.all
    @last_cigarette = Cigarette.last_cigarette
  end

  # GET /cigarettes/new
  def new
    @cigarette = Cigarette.new
  end

  # POST /cigarettes or /cigarettes.json
  def create
    @cigarette = Cigarette.new(cigarette_params)

    if @cigarette.save
      redirect_to cigarettes_path, notice: "nouvelle clope ajoutée... Dommage 😢"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cigarette
    @cigarette = Cigarette.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def cigarette_params
    params.require(:cigarette).permit(:quantity, :date)
  end
end

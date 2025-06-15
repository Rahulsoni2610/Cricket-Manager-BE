class Api::V1::TournamentsController < ApplicationController
  before_action :set_tournament, only: [:update, :destroy]

  def index
    @tournaments = Tournament.all
    render json: @tournaments
  end

  def create
    @tournament = Tournament.new(tournament_params)
    if @tournament.save
      render json: @tournament, status: :created
    else
      render json: { errors: @tournament.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @tournament.update(tournament_params)
      render json: @tournament
    else
      render json: { errors: @tournament.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @tournament.destroy
    head :no_content
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :start_date, :end_date, :tournament_type, :status, :user_id)
  end
end

class Api::V1::MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: [:show, :update, :destroy]

  def index
    @matches = Match.all
    render json: @matches
  end

  def show
    render json: @match
  end

  def create
    @match = Match.new(match_params)

    if @match.save
      render json: @match, status: :created
    else
      render json: @match.errors, status: :unprocessable_entity
    end
  end

  def update
    if @match.update(match_params)
      render json: @match
    else
      render json: @match.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @match.destroy
    head :no_content
  end

  private

  def set_match
    @match = Match.find(params[:id])
  end

  def match_params
    params.require(:match).permit(
      :user_id,
      :series_id,
      :tournament_id,
      :team1_id,
      :team2_id,
      :match_date,
      :venue,
      :match_type,
      :status,
      :toss_winner_id,
      :toss_decision,
      :result,
      :winning_team_id,
      :winning_margin,
      :man_of_the_match_id
    )
  end
end

class GamesController < ApplicationController
  def show
    @game = Game.includes(:match, home_player: :card, away_player: :card).find(params[:id])
    @match = @game.match
  end
end

class PlayersController < ApplicationController

  http_basic_authenticate_with name: 'admin', password: 'admin', except: [:index, :show]

  def show
    @player = @player.find(params[:id])
  end

  def create
    @team = Team.find(params[:team_id])
    @player = @team.players.create(player_params)
    redirect_to team_path(@team)
  end

  def edit
    @team = Team.includes(:players).find(params[:team_id])
    @player = @team.players.find(params[:id])
  end

  def update
    @team = Team.includes(:players).find(params[:team_id])
    @player = @team.players.find(params[:id])

    if @player.update(player_params)
      redirect_to team_path(@team)
    else
      render 'edit'
    end
  end

  def destroy
    @team = Team.find(params[:team_id])
    @player = @team.players.find(params[:id])
    @player.destroy
    redirect_to team_path(@team)
  end

  private
    def player_params
      params.require(:player).permit(:name, :role)
    end

end

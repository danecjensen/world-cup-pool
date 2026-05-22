class Admin::TeamsController < Admin::BaseController
  def index
    @teams = Team.includes(:group).order("groups.letter, teams.name")
  end

  def edit
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])
    if @team.update(team_params)
      redirect_to admin_teams_path, notice: "Team updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def team_params
    params.require(:team).permit(:name, :code, :flag_emoji, :group_id)
  end
end

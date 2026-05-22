class Admin::KnockoutMatchesController < Admin::BaseController
  def index
    @matches = KnockoutMatch.includes(:home_team, :away_team, :home_slot, :away_slot).ordered
  end

  def edit
    @match = KnockoutMatch.find(params[:id])
  end

  def update
    @match = KnockoutMatch.find(params[:id])
    if @match.update(km_params)
      ScoringService.recompute_all
      redirect_to admin_knockout_matches_path, notice: "Knockout match ##{@match.number} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def km_params
    params.require(:knockout_match).permit(:home_score, :away_score, :kickoff_at, :venue, :home_team_id, :away_team_id)
  end
end

class Admin::MatchesController < Admin::BaseController
  def index
    @matches = Match.includes(:home_team, :away_team, :group).ordered
  end

  def edit
    @match = Match.find(params[:id])
  end

  def update
    @match = Match.find(params[:id])
    @match.assign_attributes(match_params)
    @match.result = @match.derive_result
    if @match.save
      ScoringService.recompute_all
      redirect_to admin_matches_path, notice: "Match ##{@match.number} updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def match_params
    params.require(:match).permit(:home_score, :away_score, :kickoff_at, :venue)
  end
end

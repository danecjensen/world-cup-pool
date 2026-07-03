class DripCupController < ApplicationController
  before_action :authenticate_user!
  before_action :require_drip_cup!

  def show
    Kit.sync_from_images!
    @kit_top, @kit_bottom = Kit.random_pair
    if @kit_bottom.nil?
      redirect_to root_path, alert: "The Drip Cup needs at least two kits — none are loaded yet."
      return
    end

    @matchup_token = matchup_verifier.generate([@kit_top.id, @kit_bottom.id], expires_in: 1.hour)
    @vote_count = current_user.kit_votes.count
    render layout: "drip_cup_fullscreen"
  end

  def vote
    pair_ids = matchup_verifier.verified(params[:matchup_token])
    winner_id = params[:winner_id].to_i
    unless pair_ids.is_a?(Array) && pair_ids.include?(winner_id)
      redirect_to drip_cup_path, alert: "That matchup expired — here's a fresh one.", status: :see_other
      return
    end

    winner = Kit.find(winner_id)
    loser = Kit.find((pair_ids - [winner_id]).first)
    KitVote.record!(user: current_user, winner: winner, loser: loser)
    redirect_to drip_cup_path, status: :see_other
  end

  def leaderboard
    @kits = Kit.ranked
    @total_votes = KitVote.count
  end

  private

  def require_drip_cup!
    redirect_to root_path, alert: "The Drip Cup isn't open yet." unless drip_cup_visible?
  end

  # Matchups are signed so a vote can only be cast for a pair the app
  # actually served.
  def matchup_verifier
    Rails.application.message_verifier("drip_cup_matchup")
  end
end

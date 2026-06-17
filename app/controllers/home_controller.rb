class HomeController < ApplicationController
  def index
    @user_count = User.count
    @recent_posts = Post.approved.includes(:user, :comments, media_attachment: :blob).newest_first.limit(3)
    @first_kickoff_at = Match.minimum(:kickoff_at)
    @team_flags = Team.joins(:group).order("groups.letter", "teams.id").pluck(:flag_emoji, :name)
    next_group  = Match.where("kickoff_at > ?", Time.current).order(:kickoff_at).first
    next_ko      = bracket_visible? ? KnockoutMatch.where("kickoff_at > ?", Time.current).order(:kickoff_at).first : nil

    # The next day on which any game is played, then every game on that day.
    @next_day = [next_group&.kickoff_at, next_ko&.kickoff_at].compact.min&.in_time_zone&.to_date
    if @next_day
      day_start = @next_day.in_time_zone.beginning_of_day
      day_range = day_start..day_start.end_of_day
      @next_matches   = Match.includes(:group, :home_team, :away_team)
                             .where(kickoff_at: day_range).ordered
      @next_knockouts = bracket_visible? ? KnockoutMatch.includes(:home_team, :away_team, :home_slot, :away_slot)
                                                        .where(kickoff_at: day_range).order(:kickoff_at) : KnockoutMatch.none
    else
      @next_matches   = Match.none
      @next_knockouts = KnockoutMatch.none
    end

    if user_signed_in?
      @match_picks    = current_user.picks.where(match_id: @next_matches.map(&:id)).index_by(&:match_id)
      @knockout_picks = current_user.picks.where(knockout_match_id: @next_knockouts.map(&:id)).index_by(&:knockout_match_id)
    else
      @match_picks    = {}
      @knockout_picks = {}
    end
    @top_players = User.left_joins(:picks)
                       .group("users.id")
                       .select("users.*, COALESCE(SUM(picks.points_awarded), 0) AS total")
                       .order("total DESC")
                       .limit(5)

    if user_signed_in?
      standings = User.left_joins(:picks)
                      .group("users.id")
                      .select("users.id, users.display_name, COALESCE(SUM(picks.points_awarded), 0) AS total")
                      .order(Arel.sql("total DESC, users.display_name ASC"))
                      .to_a

      @leader = standings.first
      if @leader
        @leader_points = @leader.total.to_i
        # Rank with ties: players sharing the same total share a rank.
        rank = 0
        last_total = nil
        standings.each_with_index do |player, index|
          total = player.total.to_i
          rank = index + 1 if total != last_total
          last_total = total
          if player.id == current_user.id
            @my_rank = rank
            @my_points = total
            break
          end
        end
        @total_players = standings.size
      end
    end
  end
end

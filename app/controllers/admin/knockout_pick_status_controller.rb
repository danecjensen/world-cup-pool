class Admin::KnockoutPickStatusController < Admin::BaseController
  def index
    @users = User.order(Arel.sql("LOWER(display_name)"))
    @total_matches = KnockoutMatch.count
    @picks_by_user = Pick.where.not(knockout_match_id: nil)
                         .group(:user_id)
                         .count
  end
end

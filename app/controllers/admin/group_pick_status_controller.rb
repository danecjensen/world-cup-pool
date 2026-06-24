class Admin::GroupPickStatusController < Admin::BaseController
  def index
    @users = User.order(Arel.sql("LOWER(display_name)"))
    @total_matches = Match.count
    @picks_by_user = Pick.where.not(match_id: nil)
                         .where.not(group_result: nil)
                         .group(:user_id)
                         .count
  end
end

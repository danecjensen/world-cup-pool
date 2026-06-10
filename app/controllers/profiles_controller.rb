class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    load_picks
  end

  def update_name
    if current_user.update(display_name: params.require(:user)[:display_name])
      redirect_to profile_path, notice: "Username updated."
    else
      load_picks
      @name_errors = current_user.errors.full_messages
      current_user.reload
      render :show, status: :unprocessable_entity
    end
  end

  def update_password
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to profile_path, notice: "Password updated."
    else
      load_picks
      @password_errors = current_user.errors.full_messages
      current_user.reload
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def load_picks
    @groups = Group.includes(matches: [:home_team, :away_team]).order(:letter)
    @picks_by_match = current_user.picks.where.not(match_id: nil).index_by(&:match_id)
  end
end

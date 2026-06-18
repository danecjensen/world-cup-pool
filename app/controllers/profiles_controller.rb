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

  def flag
    load_world_cup_nations
  end

  def update_flag
    nation = params.require(:user)[:support_nation].to_s.strip
    flag = NationFlag.for(nation)

    if nation.blank?
      current_user.update(support_nation: nil, support_flag: nil)
      redirect_to profile_path, notice: "Flag removed from your name."
    elsif flag
      current_user.update(support_nation: nation, support_flag: flag)
      redirect_to profile_path, notice: "#{flag} added to your name. Go #{nation}!"
    else
      load_world_cup_nations
      @flag_error = "We couldn't find a flag for \"#{nation}\". Pick one of the World Cup nations from the list."
      render :flag, status: :unprocessable_entity
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

  # The 48 nations in the tournament, used to populate the flag picker.
  def load_world_cup_nations
    @world_cup_nations = Team.alphabetical.pluck(:name)
  end
end

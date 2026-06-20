class WatchPartiesController < ApplicationController
  before_action :authenticate_user!

  def create
    @watch_party = current_user.watch_parties.build(watch_party_params)

    if @watch_party.save
      redirect_to profile_path, notice: "Watch party posted! Folks can now see where to meet up."
    else
      redirect_to profile_path, alert: @watch_party.errors.full_messages.to_sentence
    end
  end

  def destroy
    @watch_party = current_user.watch_parties.find(params[:id])
    @watch_party.destroy
    redirect_to profile_path, notice: "Watch party removed."
  end

  private

  def watch_party_params
    params.require(:watch_party).permit(:location, :match_id, :match_label)
  end
end

class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :group_stage_locked?, :knockout_stage_locked?, :bracket_visible?

  def bracket_visible?
    SiteSetting.current.bracket_visible?
  end

  def group_stage_locked?
    @group_stage_locked ||= Match.minimum(:kickoff_at).then { |t| t.present? && t <= Time.current }
  end

  def knockout_stage_locked?
    @knockout_stage_locked ||= KnockoutMatch.where(round: "r32").minimum(:kickoff_at).then { |t| t.present? && t <= Time.current }
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:display_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  def require_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "Admin access required."
    end
  end
end

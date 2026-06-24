class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :group_stage_locked?, :knockout_stage_locked?,
                :bracket_visible?, :knockout_visible?, :knockout_preview?

  # Feature flag: when on, the knockout bracket is live for every user.
  def bracket_visible?
    SiteSetting.current.bracket_visible?
  end

  # Whether the current viewer may see the knockout bracket at all.
  # Once the flag is on it's live for everyone; while it's off, admins can
  # still reach it to test the feature before it ships.
  def knockout_visible?
    bracket_visible? || admin_user?
  end

  # True only when an admin is previewing the knockout section before the
  # feature flag has been switched on for everyone. Used to surface
  # "not live yet" messaging in the UI.
  def knockout_preview?
    !bracket_visible? && admin_user?
  end

  def group_stage_locked?
    @group_stage_locked ||= Match.minimum(:kickoff_at).then { |t| t.present? && t <= Time.current }
  end

  def knockout_stage_locked?
    @knockout_stage_locked ||= KnockoutMatch.where(round: "r32").minimum(:kickoff_at).then { |t| t.present? && t <= Time.current }
  end

  def admin_user?
    user_signed_in? && current_user.admin?
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:display_name]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  def require_admin!
    unless admin_user?
      redirect_to root_path, alert: "Admin access required."
    end
  end
end

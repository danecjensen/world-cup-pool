module ApplicationHelper
  def pool_name
    ENV.fetch("POOL_NAME", "World Cup 2026 Pool")
  end

  def pool_tagline
    ENV.fetch("POOL_TAGLINE", "2026 FIFA World Cup Pool · single shared pool · open registration")
  end

  # Whether the signed-in user may delete the given post/comment — true for the
  # author and for any admin (so admins can moderate the feed).
  def can_moderate?(record)
    return false unless user_signed_in?
    record.user_id == current_user.id || current_user.admin?
  end
end

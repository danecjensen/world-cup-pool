class Developer::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  SKIP_IN_FORMS = %w[
    id created_at updated_at
    encrypted_password reset_password_token reset_password_sent_at remember_created_at
  ].freeze

  helper_method :developer_models, :skip_in_forms

  private

  def developer_models
    Rails.application.eager_load! unless Rails.application.config.eager_load
    ApplicationRecord.descendants
                     .reject(&:abstract_class?)
                     .select { |k| k.table_exists? }
                     .sort_by(&:name)
  end

  def skip_in_forms
    SKIP_IN_FORMS
  end

  def find_model(slug)
    return nil if slug.blank?
    klass = slug.classify.safe_constantize
    return nil unless klass.is_a?(Class) && klass < ApplicationRecord && klass.table_exists?
    klass
  end
end

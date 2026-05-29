class SiteSetting < ApplicationRecord
  def self.current
    first_or_create!
  end
end

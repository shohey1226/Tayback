class SiteUser < ActiveRecord::Base
  belongs_to :site
  belongs_to :user
  default_scope { order('accessed_at DESC') }
end

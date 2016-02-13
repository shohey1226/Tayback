class BlockerUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :blocker
  belongs_to :site
  default_scope { order('used_at DESC') }
end

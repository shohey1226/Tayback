class BlockerUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :blocker
  belongs_to :site
end

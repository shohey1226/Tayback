class BlockerSite < ActiveRecord::Base
  belongs_to :site
  belongs_to :blocker
end

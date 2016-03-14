class Site < ActiveRecord::Base
  has_many :blocker_users
  has_many :blockers, through: :blocker_users

  def blocker_count(blocker_id)
    self.blockers.where(id: blocker_id).count
  end
end

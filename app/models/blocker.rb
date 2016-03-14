class Blocker < ActiveRecord::Base

  def owner
    if self.created_by.nil?
      nil
    else
      User.find_by_id(self.created_by)
    end
  end

end

class User < ActiveRecord::Base

  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :site_users
  has_many :sites, :through => :site_users
  has_many :blocker_users
  has_many :blockers, :through => :blocker_users


  def url_list
    self.sites.order('accessed_at DESC').map{|site|
      blockers = self.blockers.where(site: site).order('accessed_at DESC')
      {
        url: site.url,
        blockerList: blockers
      }
    }
  end

end

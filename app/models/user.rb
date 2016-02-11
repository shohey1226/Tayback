class User < ActiveRecord::Base

  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  has_many :site_users
  has_many :sites, :through => :site_users
  has_many :blocker_users
  has_many :blockers, :through => :blocker_users

  attr_accessor :login

  def url_list
    SiteUser.where(user: self).order('accessed_at DESC').map{|site_user|
      blocker_list = []
      BlockerUser.where(user: self, site: site_user.site).order('used_at DESC').each{|blocker_user|
        blocker_list.push({
          title: blocker_user.blocker.title,
          rule: blocker_user.blocker.rule
        })
      }
      {
        url: site_user.site.url,
        blockerList: blocker_list
      }
    }
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
    else
      where(conditions).first
    end
  end

end

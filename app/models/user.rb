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

  def get_urls
    urls = Site.where(locale: self.locale).order('count DESC').limit(50)
    .map{|site| { url: site.url } }
    if urls.blank?
      []
    else
      urls
    end
  end

  def delete_blocker_relation(blocker_id)
    blocker = self.blocker_users.find_by(blocker: blocker_id)
    if blocker.present?
      blocker.destroy
    else
      false
    end
  end



  def find_or_create_blocker(blocker_params)
    blocker = blocker_params[:id].present? ? Blocker.find_by_id(blocker_params[:id]) : nil
    unless blocker.present?
      blocker = Blocker.create!(title: blocker_params[:title], rule: blocker_params[:rule], created_by: self.id)
    end
    return blocker
  end

  def find_or_create_site(site_params)
    site = site_params[:url].present? ? Site.find_by(url: site_params[:url], locale: self.locale) : nil
    unless site.present?
      site = Site.create!(url: site_params[:url], locale: self.locale)
    end
    return site
  end

  def make_blocker_site_relation(blocker, site)
    self.sites << site if self.sites.find_by_id(site.id).blank?
    self.site_users.find_by(site: site).update!(accessed_at: Time.now)
    self.blockers << blocker if self.blockers.find_by_id(blocker.id).blank?
    self.blocker_users.find_by(blocker: blocker).update!(used_at: Time.now, site: site)
  end

  # update only if it's mine
  def update_blocker(blocker_params)
    my_blocker = Blocker.find_by(created_by: self, id: blocker_params[:id])
    if my_blocker.present?
      my_blocker.update(title: blocker_params[:title], rule: blocker_params[:rule])
      my_blocker
    else
      nil
    end
  end

  def url_list
    self.site_users.map{|site_user|
      blocker_ids = self.blocker_users.where(site: site_user.site).map(&:blocker_id)
      blocker_list = Blocker.where(id: blocker_ids).index_by(&:id).values_at(*blocker_ids).map{|blocker|
        {
          id: blocker.id,
          title: blocker.title,
          rule: blocker.rule
        }
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

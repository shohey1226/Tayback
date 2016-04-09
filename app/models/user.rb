class User < ActiveRecord::Base

  acts_as_token_authenticatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  has_many :site_users
  has_many :sites, -> { order 'site_users.accessed_at desc' }, :through => :site_users
  has_many :blocker_users
  has_many :blockers, :through => :blocker_users

  attr_accessor :login

  def get_urls
    urls = Site.where(locale: self.locale).order('count DESC').limit(50)
    if urls.blank?
      []
    else
      urls
    end
  end

  def get_blockers(url)
    site = Site.find_by(locale: self.locale, url: url)
    blockers = []
    if site.present?
      blocker_ids = []
      blocker_ids = BlockerUser.where(site: site).limit(50).map(&:blocker_id)
      blocker_ids.uniq!
      blockers = Blocker.where(id: blocker_ids).includes(:user).map{|blocker|
        {
          id: blocker.id,
          title: blocker.title,
          rule: blocker.rule,
          count: site.blocker_count(blocker.id),
          owner: blocker.user,
        }
      } if blocker_ids.present? && blocker_ids.count > 0

    end

    # # add default blockers if it's not included yet
    # default_blocker_ids = [1,2,3]
    # adding_blocker_ids = default_blocker_ids - (blocker_ids & default_blocker_ids)
    # blockers.concat(
    #   Blocker.where(id: adding_blocker_ids).map{|blocker|
    #     {
    #       id: blocker.id,
    #       title: blocker.title,
    #       rule: blocker.rule,
    #       count: blocker.count,
    #       owner: blocker.user,
    #     }
    #   }
    # ) if adding_blocker_ids.count > 0

    return blockers.compact
  end

  def delete_blocker_relation(blocker_id)
    blocker = self.blocker_users.find_by(blocker: blocker_id)
    if blocker.present?
      blocker.destroy
    else
      false
    end
  end

  # Executed when a new blocker is created
  def make_blocker_site_relation(blocker, site)
    self.sites << site if self.sites.find_by_id(site.id).blank?
    BlockerUser.create!(user: self, blocker: blocker, site: site)
    BlockerSite.create!(blocker: blocker, site: site)
  end

  # Executed when a user open url with blocker
  # create the relation if it doesn't exist
  def update_count_and_timestamp!(blocker, site)
    site.increment!(:count)
    now = Time.now

    site_user = self.site_users.find_by(site: site)
    if site_user.present?
      site_user.update!(accessed_at: now)
    else
      SiteUser.create!(user: self, site: site, accessed_at: now)
    end

    blocker_user = self.blocker_users.find_by(blocker: blocker)
    if blocker_user.present?
      blocker_user.update!(used_at: now)
    else
      BlockerUser.create!(user: self, blocker: blocker, site: site, used_at: now)
    end

    blocker_site = BlockerSite.find_by(blocker: blocker, site: site)
    if blocker_site.present?
      blocker_site.increment!(:count)
    else
      BlockerSite.create!(blocker: blocker, site: site, count: 1)
    end
  end

  # update only if it's mine
  def update_blocker(blocker_params)
    my_blocker = Blocker.find_by(user_id: self, id: blocker_params[:id])
    if my_blocker.present?
      my_blocker.update(title: blocker_params[:title], rule: blocker_params[:rule])
      my_blocker
    else
      nil
    end
  end

  # Get my UrlList
  def url_list
    self.sites.where(locale: self.locale).limit(50).map{|site|
      blocker_list = self.blocker_users.where(site: site).order('used_at desc').limit(50).map{|blocker_user|
        blocker = blocker_user.blocker
        # owner can be nil when it's default
        owner = blocker.user.present? ? { id: blocker.user.id, username: blocker.user.username, locale: blocker.user.locale } : nil
        {
          id: blocker.id,
          title: blocker.title,
          rule: JSON.parse(blocker.rule),
          count: BlockerSite.find_by(blocker: blocker, site: site).count,
          owner: owner
        }
      }
      {
        url: site.url,
        title: site.title,
        count: site.count,
        blockerList: blocker_list,
      }
    }.compact # remove nil for skipped by next
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

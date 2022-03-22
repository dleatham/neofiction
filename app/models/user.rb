class User < ActiveRecord::Base
  #######################################################################
  # Custom exceptions/errors
  class EULANotAgreed < StandardError
  end
  
  class UpdateEulaFailed < StandardError
  end
  
  ##############################################################################
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  ##############################################################################
  # Accessible (or protected) attributes for this model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :roles_mask, :roles, :name, :activity_score, :popularity_score,
                  :eula_agree, :blog_url, :bio
                  
  ##############################################################################
  # Relationships for this model
  has_many :stories
  has_many :chapters
  has_many :comments
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :tracks, :dependent => :destroy
  has_many :tracked_stories, :through => :tracks, :source => :trackable, :source_type => "Story"
  has_many :tracked_chapters, :through => :tracks, :source => :trackable, :source_type => "Chapter"
  acts_as_voter
  has_karma(:chapters, :as => :user)  # tracks "up votes" for all a user's chapters 
  
 
  ##############################################################################
  # validations  
  validates(:email, :uniqueness => true, :presence => true, :format => /^.+@.+/ )
  validates(:blog_url, :allow_blank => true, :format => URI::regexp(%w(http https)))
  
  ##############################################################################  
  # Callbacks
  after_create do
    # ensure there is a membership for this user in the default/public group
    Membership.create!( :user_id => self.id, :group_id => Group::DEFAULTGROUPID, :group_role => "none - public group" )
  end


  
  ##########################################################################
  # allow cancan's key current_user methods to be called from this user model
  # https://github.com/ryanb/cancan/wiki/ability-for-other-users
  delegate :can?, :cannot?, :unauthorized_message,  :to => :ability
  
  ##############################################################################
  #  Adding the cancan ability method to the user model
  #  https://github.com/ryanb/cancan/wiki/ability-for-other-users
  
  def ability
    @ability ||= Ability.new(self)
  end
  
  def current_ability
    self.ability
  end 
  
  # This is a copy of the CanCan authorize! method, adjusted to call user.can?
  # implemented because authorize! stopped working after adding cancan ability to user model.
  # Couldn't debug the issue.  Added this as a work around.
  def authorize!(action, subject, *args)
    message = nil
    if args.last.kind_of?(Hash) && args.last.has_key?(:message)
      message = args.pop[:message]
    end
    if self.cannot?(action, subject, *args)
      message ||= unauthorized_message(action, subject)
      raise CanCan::AccessDenied.new(message, action, subject)
    end
    subject
  end

  ##############################################################################
  # Tracking
  
  def tracking?(trackable_object)
    !(
      Track.where("trackable_type = ? AND trackable_id = ? AND user_id = ?", 
                 trackable_object.class.name, trackable_object.id, self.id).
                 empty?
      )
  end
  
  def tracked_objects(object_class)
    tracked = []
    self.tracks.where("trackable_type = '#{object_class}'").each do |t|
      tracked << object_class.constantize.find(t.trackable_id)
    end
    tracked
  end
  
  ##############################################################################
  # scoring and ratings...  
  def weighted_score
    activity_score + popularity_score
  end
  
  def update_activity_score
    stories = self.stories.count  # 3 activity points per story
    chapters = self.chapters.count  # 5 activity points per chapter
    comments = self.comments.count  # 2 activity point per comment
    votes = self.vote_count :all  # 1 activity point per vote
    
    self.activity_score = (stories * 3) + (chapters * 5) + (comments * 2) + (votes * 1)
    self.save
  end
  
  def update_popularity_score
    # one popularity point for each chapter in a user's stories
    story_pop = 0
    self.stories.each do |story|
      story.chapters.each do |chapter|
        story_pop += chapter.descendant_ids.count
      end
    end
    # one popularity point for each comment on a user's chapters
    chapter_pop = 0
    self.chapters.each do |chapter|
      chapter_pop += chapter.comments.count
    end
    # Add in the thumbs_up "karma" (number of chapters that have recieved positive votes)
    karma = self.karma
    
    self.popularity_score = (story_pop + chapter_pop + karma) * 10
    self.save
  end


  ##############################################################################  
  # user roles and scope
  ROLES = %w[visitor reader writer author support admin]
  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0"} }
  
  ##############################################################################  
  # setter method
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  ##############################################################################   
  # getter method
  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  
  ##############################################################################  
  # role symbols
  def role_symbols
    roles.map(&:to_sym)
  end
  
  ##############################################################################  
  # Boolean role method
  def role?(role)  
    roles.include? role.to_s  
  end  
       
end

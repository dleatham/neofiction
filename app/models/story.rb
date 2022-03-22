class Story < ActiveRecord::Base
  
  # since this is a polymorphic class based on :trackable, get trackers() method from SharedMethods model
  include SharedMethods
  # load 'shared_methods.rb'

  #################################################
  # Accessible (or protected) attributes for this model
  attr_accessible :title, :desc, :activity, :user_id, :group_id, :genre_id
  attr_accessible :comments, :published
  
  #################################################
  # Relationships for this model
  belongs_to :user
  belongs_to :group
  belongs_to :genre
  belongs_to :trackable, :polymorphic => true
  has_many :chapters, :through => :first_chapters, :dependent => :destroy
  has_many :first_chapters
  has_many :comments, :as => :commentable
  has_many :users, :through => :tracks, :source => :user
  accepts_nested_attributes_for :comments
  
  #################################################
  # call backs
  after_create :ensure_eula_agreement
  
  ##############################################################################
  # validations  
  
  ########################################################
  # As a default, Story needs to belong to the default/
  # public group.
  def initialize( *p )  # expects some params when called from Rake...????
    super
    self.group_id = Group::DEFAULTGROUPID
    self.genre_id = Genre::DEFUALTGENREID
  end
    
  
  ########################################################
  #  create a new first/root chapter for the story
  def new_root_chapter(user)
    chapter = Chapter.new
    chapter.parent = nil  # set as a root node
    chapter.user_id = user.id
    chapter.save!
    
    #set up a link between the story and the new root chapter
    first_chapter = FirstChapter.new
    first_chapter.chapter_id = chapter.id
    first_chapter.story_id = self.id
    first_chapter.save
    return chapter
  end
  
  
  ########################################################
  # update the activity attribute by counting chapters and votes 
  def update_activity
    activity = 0
    self.chapters.each do |chapter|
      activity += 5  # five activity points per chapter added
      activity += (chapter.comments.count * 2)  # 2 points per comment added
      activity += (chapter.votes_for + chapter.votes_against)  # 1 point per vote
    end
    activity += (self.comments.count * 2)
    self.activity = activity
    self.save!
  end
  
  ##################################################################################
  #  get the story's most popular chapter.  If user is not supplied could return private records.
  def most_pop_chapter( user=nil )
    if user==nil
      self.chapters.where( "published = ?", true ).order("vote_cnt DESC").first 
    else
      self.chapters.where( "published = ?", true ).accessible_by(user.current_ability).order("vote_cnt DESC").first       
    end
  end

  ##################################################################################
  #  get all published opening chapters, regardless of user status
  def published_opening_chapters
    self.first_chapters.chapters.where( "published = ?", true )
  end

  ##################################################################################
  #  get the story's published and accessible opening/first chapters. If user is not supplied could return private records.
  def opening_chapters( user=nil)
    if user==nil
      self.chapters.where( "published = ?", true ).order("vote_cnt DESC") 
    else
      self.chapters.where( "published = ?", true ).accessible_by(user.current_ability).order("vote_cnt DESC") 
    end
  end
  
  ##################################################################################
  def total_published_chapters
    first_chap = self.first_chapters.find(:first).chapter
    decsendants = first_chap.descendants
    decsendants.delete_if {|x| x.published == false }.count + 1  # add 1 for the first chapter itself 
  end
  
  ###################################################################################
  # Users that are tracking this story
  # trackers() method is available for this object via SharedMethods in /lib
  

  #################################################################################
  # SEO Friendly URL 
  extend FriendlyId
  friendly_id :genre_title, use: [:slugged, :history]
  
  def genre_title
       "#{self.genre.title} #{self.title}"
  end
  
  
  private
  
  ##################################################################################
  #  Enusre that a new story cannot be created by a user that has not agreed to the eula
  def ensure_eula_agreement
    raise User::EULANotAgreed unless self.user.eula_agree
  end 

  
end

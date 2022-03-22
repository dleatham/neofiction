class Chapter < ActiveRecord::Base
  
  # since this is a polymorphic class based on :trackable, get trackers() method from SharedMethods model
  include SharedMethods
  # load 'shared_methods.rb'
  
  #################################################
  # Accessible (or protected) attributes for this model
  # TODO :votes and :published need to be made non-accessible with getter and setter methods
  attr_accessible :heading, :body, :notes, :published, :user_id, :group_id, :vote_cnt
  # attr_accessible :vote_count -- DEPRECATED due to a namespace conflict with the thumbs_up gem
  
  
  #################################################
  # Relationships for this model
  belongs_to :user
  belongs_to :group
  belongs_to :trackable, :polymorphic => true
  has_many :comments
  accepts_nested_attributes_for :comments
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :users, :through => :tracks, :source => :user
  has_ancestry 
  acts_as_voteable
  
  #################################################
  # call backs
  after_create :ensure_eula_agreement
  
  ########################################################
  #  queries
  def published_siblings
    if self.is_root?
      the_story = self.story
      the_story.chapters.where("chapter_id <> :id", :id => self.id).where("published = :published", :published => true)
    else
      self.siblings.where("id <> :id", :id => self.id).where("published = :published", :published => true)
    end
  end  
  
  def published_children
    self.children.where( "published = ?", true ).order('vote_cnt DESC')
  end
   
  ###################################################################################
  # Users that are tracking this story
  # trackers() method is available for this object via SharedMethods in /lib
  
  ##############################################################################
  # Set up the new record with generic data in the fields  
  # Needs to belong to the DEFAULTGROUPID to be publically seen
  def initialize
    super
    self.published = false
    self.group_id = Group::DEFAULTGROUPID
    # self.vote_count = 0  --  DEPRECATED due to a namespace conflict with thumbs_up gem
    self.vote_cnt = 0
    self.heading = "<No Heading>"
  end
  
  ##############################################################################
  # returns the :story instance that contains this :chapter instance
  def story
    root_chapter = self.root
    first_chapter = FirstChapter.where( :chapter_id => root_chapter.id ).first
    if first_chapter == nil
      return nil
    else
      return Story.find(first_chapter.story_id)
    end
  end
  
  ##############################################################################  
  #  creates a new chapter instance and sets this instance as the parent
  def new_child_chapter( user )
    child_chapter = Chapter.new
    child_chapter.parent = self  # set this instance as parent of the new instance
    child_chapter.user_id = user.id
    child_chapter.save!
    child_chapter
  end
  
  ###############################################################################
  #  update the vote_cnt field in the database, for sorting and query purposes.
  #  Load the thumbs_up vote_count into the chapter's vote_cnt db field.
  def update_vote_count
    if self.vote_count != self.vote_cnt
      self.vote_cnt = self.vote_count
      self.save
    end
  end
  
  #################################################################################
  # SEO Friendly URL 
  extend FriendlyId
  friendly_id :story_chapter, use: [:slugged, :history]
  
  def story_chapter
    if self.story == nil
      "#{heading}"
    else
      "#{self.story.genre.title} #{heading}"
    end
  end
  
  private
  
  ##################################################################################
  #  Enusre that a new chapter cannot be created by a user that has not agreed to the eula
  def ensure_eula_agreement
    raise User::EULANotAgreed unless self.user.eula_agree
  end 
  
end

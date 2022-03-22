class Group < ActiveRecord::Base
  ##############################################################################
  # Each :user, :story and :chapter must belong to the default group, which is 
  # the "public" group (e.g. all stories and chapters default to "public" view)
  DEFAULTGROUPID = 1
  
  ##############################################################################
  # Accessible (or protected) attributes for this model
  attr_accessible :title, :desc, :user_id
  
  ##############################################################################
  # Relationships for this model
  belongs_to :user
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :stories
  has_many :chapters
  has_many :comments
  accepts_nested_attributes_for :memberships
  
  #############################################################################
  # Method to show/test membership
  def member?(user)
    self.user_ids.include?(user.id)
  end
end

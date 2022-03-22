class FirstChapter < ActiveRecord::Base
  #################################################
  #  This model provides a link between a :story and
  #  an initial :chapter.  The :story will have mutliple 
  #  :first_chapter instances and each  associated 
  #  :chapter will be a :root of a tree of :chapters. 
    
  #################################################
  
  #################################################
  # Accessible (or protected) attributes for this model
  attr_accessible :story_id, :chapter_id
  
  # Relationships for this model
  belongs_to :chapter
  belongs_to :story
  has_many :comments, :as => :commentable
  
end

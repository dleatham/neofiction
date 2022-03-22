class Genre < ActiveRecord::Base
  
  ##############################################################################
  # Each :story must have a default genre, which is the "generic" genre 
  DEFUALTGENREID = 1
  
  ##############################################################################
  attr_accessible :title, :desc, :ancestry, :parent_id
  
  ##############################################################################
  has_many :stories
  has_ancestry
  
  ##############################################################################
  scope :all_base_genres, where(:ancestry => nil).order("title")
  scope :fan_fiction_base_genres, where(:ancestry => nil).where("title LIKE ?", 'Fan Fiction%')
  scope :standard_base_genres, where(:ancestry => nil).where("title NOT LIKE ?", 'Fan Fiction%')
  
  ##############################################################################
  def self.all_base_genre_sorted_by_total_stories
    base_genres = self.all_base_genres
    base_genres.sort_by {|x| x.total_stories}.reverse
  end
  
  ##############################################################################
  def self.ff_base_genre_sorted_by_total_stories
    ff_base_genres = self.fan_fiction_base_genres
    ff_base_genres.sort_by {|x| x.total_stories}.reverse
  end
  
  ##############################################################################
  def self.standard_base_genre_sorted_by_total_stories
    base_genres = self.standard_base_genres
    base_genres.sort_by {|x| x.total_stories}.reverse
  end
  
  ##############################################################################
  def children_sorted_by_total_stories
    if !(self.children.empty?)
      self.children.sort_by {|x| x.total_stories}.reverse
    end
  end
    
  ###############################################################################
  def story_count
    Story.where(:published => true).where( :genre_id => self.id ).count
  end
  
  def total_stories
    count = self.story_count
    self.children.each do |child|
      if child.children.empty?
        count += child.story_count
      else
        count += child.total_stories
      end
    end
    return count
  end
  
  ###############################################################################
  # identifies a sub-genre in the conext of its base/parent genre
  def title_extended
    if self.parent == nil  # if this is a base genre then it is just the title
      self.title
    else                   # this is a sub-genre, add the base to the title
      self.title + " (" + self.parent.title + ")"
    end
  end
  
  
  #################################################################################
  # only two levels of genre allowed,  base/parent and sub/child
  def is_base_genre?
    self.parent == nil
  end
  
  def is_sub_genre?
    self.parent != nil
  end
  
end

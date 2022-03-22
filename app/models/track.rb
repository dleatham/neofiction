class Track < ActiveRecord::Base
  
  # validations
  validates :user_id, :numericality => { :only_integer => true }
  validates :trackable_id, :numericality => { :only_integer => true }
  validates :trackable_type, :presence => true 
  
  #relationships
  belongs_to :trackable, polymorphic: true
  belongs_to :user
  
end

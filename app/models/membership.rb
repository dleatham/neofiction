class Membership < ActiveRecord::Base
  
  ##############################################################################
  # Accessible (or protected) attributes for this model
  attr_accessible :user_id, :group_id, :group_role
  
  ##############################################################################
  # Relationships for this model
  belongs_to :user
  belongs_to :group 
  
  GROUPROLES = %w[member admin owner]  
end

class Comment < ActiveRecord::Base
  
  attr_accessible :title, :body, :user_id, :commentable_id, :commentable_type, :ancestry, :group_id
  
  belongs_to :user
  belongs_to :group
  belongs_to :commentable, :polymorphic => true
  has_many :comments, :as => :commentable
  has_ancestry 
  
  ######################################
  # from the DB schema:
  # t.integer  "commentable_id"
  # t.string   "commentable_type"
  
  
end

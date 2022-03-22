class Ability
  include CanCan::Ability

  ################################################################ 
  def initialize(user)
    user ||= User.new  # guest user (not logged in)
    
    # valid roles from :user model =>  ROLES = %w[visitor reader writer author support admin]
    if user.role? :admin
      can :manage, :all
    elsif user.role? :support
      can :create, :all
      can :read, :all
      can :update, :all
      can :destroy, :all
    elsif (user.role? :author) || (user.role? :writer)
      can :create, Story # unless user.role? :writer  # writers can't do Stories
      can :create, Chapter
      can :create, Group
      can :create, Comment
      can :read, Story, :group => { :id => user.group_ids }
      can :read, Chapter, :group => { :id => user.group_ids }
      can :read, Group, :group => { :id => user.group_ids }
      can :read, Comment, :group => { :id => user.group_ids }
      can :read, Genre
      # if !user.role? :writer    # writers can't do Stories
        can :update, Story, :user_id => user.id
      # end
      can :update, Chapter, :user_id => user.id
      can :update, Group, :user_id => user.id
      can :update, Comment, :user_id => user.id
      can :destroy, Chapter, :user_id => user.id
      can :destroy, Story, :user_id => user.id
    elsif user.role? :reader
      can :read, Story, :group => { :id => user.group_ids }
      can :read, Chapter, :group => { :id => user.group_ids }
      can :read, Group, :group => { :id => user.group_ids }
      can :read, Genre
      can :create, Comment
      can :update, Comment, :user_id => user.id
      can :read, Comment, :group => { :id => user.group_ids }
      can :destroy, Comment, :user_id => user.id
    else 
      # site visitor
      # create a fake group_ids array that contains only the public/default group id
      public_id = Array.new
      public_id[0] = Group::DEFAULTGROUPID
      can :read, Story, :group => { :id => public_id }
      can :read, Chapter, :group => { :id => public_id }
      can :read, Group, :group => { :id => public_id }
      can :read, Genre
      # can :read, Story, :group => { :id => user.group_ids }
      # can :read, Chapter, :group => { :id => user.group_ids }
      # can :read, Group, :group => { :id => user.group_ids }
    end
  end
   
  ################################################################ 
  # authorizations for the "support" role
  def support_can(user)
  end
  
  ################################################################ 
  # authorizations for the "author" and "writer" roles
  def author_writer_can(user)
  end
  
  
  ################################################################ 
  # authorizations for the "reader" role
  def reader_can(user)
  end
  
  ################################################################ 
  # authorizations for the "visitor" role
  def visitor_can(user)
  end
end

class PagesController < ApplicationController

  def home
    @user = current_user
    # @all_genres = Genre.all_base_genre_sorted_by_total_stories
    @fan_fiction_base_genres = Genre.ff_base_genre_sorted_by_total_stories
    @standard_base_genres = Genre.standard_base_genre_sorted_by_total_stories
    @active_stories = Story.where("published = ?", true ).accessible_by(current_ability).order("activity DESC").limit(10)
    @new_stories = Story.where("published = ?", true ).accessible_by(current_ability).order("created_at DESC").limit(10)
    @top_writers = User.where("id > 2").where("activity_score <> 0").select('*, popularity_score + activity_score as score').order('score DESC').limit(10)
    
    if current_user
      @call_to_action = "Or start your own amazing story and see where the neoFICTION community takes it."
      @tracked_stories = current_user.tracked_stories.limit(5)
      @tracked_chapters = current_user.tracked_chapters.limit(5)
    else
      @call_to_action = "To contribute votes, commentary and writing to these amazing stories, or even write your own, you will need to sign up."
    end
  end
  
  def license
  end
  
  def writers
    User.all do |u|
      u.update_popularity_score
    end 
  end
  
  def readers
  end
  
  def contact
  end
  
  def about
  end
 
  def news
  end
  
  def newest
    @new_stories = Story.where("published = ?", true ).accessible_by(current_ability).order("created_at DESC").page(params[:new_page]).per(10)
  end
  
  def active
    # get four-five pages of active stories and update their activity scores for display accuracy
    active_stories = Story.where("published = ?", true ).order("activity DESC").limit(50)
    active_stories.each do |story|
      story.update_activity
    end
    
    # retrieve the most active stories
    @active_stories = Story.where("published = ?", true ).accessible_by(current_ability).order("activity DESC").page(params[:active_page]).per(10)
  end
  
  def terms_of_service
  end
  
  ##########################################
  #  routes error-handling action
  def not_found
    logger.error("There was a AcctionController::RoutingError.")
    flash[:error] = "The page or feature requested does not exist.  If this error persists, please contact neoFICTION Support. (Requested: " + 
                    params[:path] + ")"
    redirect_to :root
  end

end

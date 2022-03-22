class StoriesController < ApplicationController
  
  
  # TODO need before_filter - user sign-in required for: :new, :create, :edit, :update, :destroy

  ################################################################  
  def index
    @stories = Story.all
    @stories.each do |story|
      story.update_activity
    end
    # now that all stories have had an activity update, display only the accessible ones
    @stories = Story.where("published = ?", true ).accessible_by(current_ability).order("activity DESC").page(params[:page]).per(10)
  end
  
  ################################################################
  def all_stories
    # authorize! :read, @stories
    @stories = Story.all
    @stories.each do |story|
      story.update_activity
    end
    # now that all stories have had a story update, display only the accessible ones
    @stories = Story.accessible_by(current_ability).order("activity DESC")
  end
  
  ################################################################
  def a_story
    @story = Story.find(params[:id])
    current_user.authorize! :read, @story
    @story.update_activity
    @user = @story.user
  end
  
  ################################################################
  def tree_view
    @story = Story.find(params[:id])
    
    all_first_chapters = @story.first_chapters.all
    ordered_first_chapters = all_first_chapters.sort_by {|x|
      x.chapter.vote_cnt
    }
    
    @root_chapter_subtrees = []
    ordered_first_chapters.each do |fc|
    @root_chapter_subtrees << fc.chapter.subtree.arrange(:order => 'vote_cnt DESC')
    end
    
  end

  ################################################################
  def show
    @story = Story.find(params[:id])
    @user = current_user
    if request.path != story_path(@story)
      redirect_to @story, status: :moved_permanently
    end

    # show the story if it's (published) or (possibly unpublished and the story owner is viewing it)
    if (@story.published) || (current_user && (current_user.id == @story.user.id))
      @story_comments = @story.comments.order("created_at ASC").page(params[:page]).per(10)
      # blank comment to be filled in by current_user
      @comment = Comment.new
      @story.update_activity
      
      # total chapter count includes all decendants from the root chapter plus the root chapter itsself
      root_chapter = @story.first_chapters[0].chapter
      decendants_count = root_chapter.descendants.where( "published = ?", true ).count
      @chapter_count = (decendants_count + 1).to_s
      
      # set tree data for display
      @root_chapter_subtree = root_chapter.subtree.arrange(:order => 'vote_cnt DESC')
 
    else 
      # unpublished and it's not the owner, so they can't see it
      redirect_to :root, :notice => "That story has not been published by the author."
    end
  end

  ################################################################
  def new
    if !current_user.eula_agree
      raise User::EULANotAgreed
    end
    @user = current_user
    @story = @user.stories.new :user => current_user
    current_user.authorize! :create, @story
    @chapter = Chapter.new 
    current_user.authorize! :create, @chapter 
    @base_genres = Genre.all_base_genres
  end

  ################################################################
  def create
    if !current_user.eula_agree
      raise User::EULANotAgreed
    end
    @user = current_user
    @story = @user.stories.new(params[:story])
    current_user.authorize! :create, @story
    # genre_id is a string in params - need to convert it to integer before it can be loaded into the story object
    @story.genre_id = params["story"]["genre_id"].to_i
    
    if @story.save
      # story is good, now save the chapter, due to a parameter bug I couldn't figure out, need to 
      # manually extract and save the chapter values in params[]
      new_blank_first_chapter
      @chapter.body = params[:chapter][:body]
      @chapter.heading = params[:chapter][:heading]
      @chapter.notes = params[:chapter][:notes]
      @chapter.save
      if !@story.published
        redirect_to story_path( @story ), :notice => "Successfully created story.  It will not be visible to others until published."
      else
        redirect_to story_path( @story ), :notice => "Successfully created story."
      end
    else
      render :action => 'new'
    end
  end

  ################################################################
  def edit
    @user = current_user
    @story = @user.stories.find(params[:id])
    current_user.authorize! :update, @story
    @chapter = @story.first_chapters.find(:first).chapter
    # if the story has no chapters, create a new first chapter
    if @chapter == nil
      new_blank_first_chapter
    end
  end

  ################################################################
  def update
    @user = current_user
    @story = Story.find(params[:id])
    current_user.authorize! :update, @story
    if @story.update_attributes(params[:story])
      @story.update_activity
      if @chapter = @story.first_chapters.find(:first).chapter
        @chapter.body = params[:chapter][:body]
        @chapter.heading = params[:chapter][:heading]
        @chapter.notes = params[:chapter][:notes]
        @chapter.published = @story.published
        @chapter.save
      end
      if !@story.published
        redirect_to story_path( @story ), :notice => "Successfully updated story.  It will not be visible to others until published."
      else
        redirect_to story_path( @story ), :notice => "Successfully updated story."
      end
    else
      render :action => 'edit'
    end
  end

    ################################################################
    def update_comment
      @user = current_user
      @story = Story.find(params[:id])
      @comment = @story.comments.new
      @comment.user_id = current_user.id
      @comment.parent = nil
      current_user.authorize! :update, @comment
      if @comment.update_attributes(params[:comment])
        @story.update_activity
        redirect_to story_path( @story ), :notice  => "Successfully updated comment on this story."
      else
        render :action => 'edit'
      end
    end

  ################################################################
  def destroy
    @user = current_user
    @story = Story.find(params[:id])
    if !@story.published
      current_user.authorize! :destroy, @story
      # first, destroy any root chapters created with the story (should only be one)
      @story.chapters.each do |c|
        c.destroy
      end
      # second, destory the story record, which in turn destroys the FirstChapter record
      @story.destroy
      redirect_to user_profile_path( current_user ), :notice => "Successfully deleted story."
    else
      redirect_to :back, :notice => "Cannot delete a published story."
    end
  end
  
  ###################################################################
  def new_blank_first_chapter
    @chapter = Chapter.new()
    @chapter.published = @story.published
    @chapter.user_id = current_user.id
    @chapter.parent = nil
    @chapter.save
    # now join the story and the chapter with a first_chapter recordfirst_chapter = FirstChapter.new
    first_chapter = FirstChapter.new
    first_chapter.chapter_id = @chapter.id
    first_chapter.story_id = @story.id
    first_chapter.save  
    
  end
  
  
end

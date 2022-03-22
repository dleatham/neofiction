class ChaptersController < ApplicationController
  
  # TODO need before_filter - user sign-in required for: all actions but :show
  
  ################################################################
  def index
    @user = User.find(params[:user_id])
    @chapters =@user.chapters.accessible_by(current_ability).order("vote_cnt DESC")
    @chapters.each do |chapter|
      chapter.update_vote_count
    end
    #reload the chapters now that the ordering field has been updated 
    @chapters =@user.chapters.accessible_by(current_ability).order("vote_cnt DESC")
  end

  ################################################################
  def show
    @chapter = Chapter.find(params[:id])
    # check for an old path using an old slug and redirect as necessary
    if request.path != chapter_path(@chapter)
      redirect_to @chapter, status: :moved_permanently
    end
    
    if (@chapter.published) || ((current_user) && (@chapter.user == current_user))
      # published or it is being shown to the author
      @parent = @chapter.parent
      @published_children = @chapter.published_children
      @chapter_comments = @chapter.comments.order("created_at ASC")
      @level = @chapter.depth + 1 
      @published_siblings = @chapter.published_siblings
    
    	if !@chapter.published_children.empty?
    	  @create_next_chapter_heading = "Think the story should go a different way?  Can you write a better chapter?  Write your own Chapter " + (@level + 1).to_s + "!"
    	else 
    	  @create_next_chapter_heading = "Keep the story going!  Be the first to write a Chapter " + (@level + 1).to_s 
    	end
  	
      @comment = @chapter.comments.new
      @story = @chapter.story
    else 
      # unpublished and it's not the owner, so they can't see it
      redirect_to :root, :notice => "That chapter has not been published by the author."
    end
    
  end

  ################################################################
  def new
    @user = current_user
    if !current_user.eula_agree
      raise User::EULANotAgreed
    end
    @chapter = @user.chapters.new
    current_user.authorize! :create, @chapter
    
  end
  
  ################################################################
  def new_chapter
    @user = current_user
    @parent_chapter = Chapter.find( params[:id] )
    if !current_user.eula_agree
      raise User::EULANotAgreed
    end
    @chapter = @parent_chapter.new_child_chapter( @user )
    current_user.authorize! :create, @chapter
    redirect_to edit_chapter_path( @chapter ), :notice => "Newly created chapter ready for editing. It must be made public for others to see."
  end

  ################################################################
  def create
    @user = current_user
    if !current_user.eula_agree
      raise User::EULANotAgreed
    end
    @chapter = @user.chapters.new(params[:chapter])
    current_user.authorize! :create, @chapter
    if @chapter.save
      if !@chapter.published
        notice_text = "Chapter sucessfully created, but not published!  It will not be viewable by others until published."
      else
        notice_text = "Chapter sucessfully created!"
      end
      redirect_to chapter_path(@chapter), :notice => notice_text
    else
      render :action => 'new'
    end
  end

  ################################################################
  def edit 
    self.current_user ||= User.new
    @user = current_user
    @chapter = Chapter.find(params[:id])
    @story = @chapter.story
    #if this is the root chapter then it must be edited via the story information
    if @chapter.parent == nil
      redirect_to edit_story_path( @story )
    end
    @user.authorize! :update, @chapter

  end

  ################################################################
  def update
    self.current_user ||= User.new
    @user = current_user
    @chapter = Chapter.find(params[:id])
    current_user.authorize! :update, @chapter
    if @chapter.update_attributes(params[:chapter])
      if !@chapter.published
        notice_text = "Chapter sucessfully updated, but not published!  It will not be viewable by others until published."
      else
        notice_text = "Chapter sucessfully updated!"
      end
      redirect_to chapter_path( @chapter ), :notice => notice_text
    else
      render :action => 'edit'
    end  
  end  

  ################################################################
  def create_comment
    @user = User.find(params[:comment][:user_id])
    @chapter = Chapter.find(params[:id])
    @comment = @chapter.comments.new
    @user.authorize! :create, @comment
    @comment.parent = nil
    @comment.user_id = @user.id
    if @comment.update_attributes(params[:comment])
       redirect_to chapter_path( @chapter ), :notice  => "Successfully created comment on this chapter."
    else
      render :action => 'edit'
    end
  end
  
  ################################################################
  def vote_for
    @chapter = Chapter.find(params[:id])
    begin # try-rescue
      current_user.vote_for(@chapter = Chapter.find(params[:id]))
      redirect_to chapter_path( @chapter ), :notice  => "Successfully voted for this chapter."
    rescue
      redirect_to chapter_path( @chapter ), :notice  => "Sorry, can't vote for a chapter twice, or you don't have voting privilages."      
    end
  end

  ################################################################
  def vote_against
    @chapter = Chapter.find(params[:id])
    begin # try-rescue
      current_user.vote_against(@chapter = Chapter.find(params[:id]))
      redirect_to chapter_path( @chapter ), :notice  => "Successfully voted against this chapter."
    rescue
      redirect_to chapter_path( @chapter ), :notice  => "Sorry.  You can't \"un-vote\" for a chapter."
    end
  end

  ################################################################
  def destroy
    @user = current_user
    @chapter = @user.chapters.find(params[:id])
    if !@chapter.published
      current_user.authorize! :destroy, @chapter
      @chapter.destroy
      redirect_to user_profile_path( current_user), :notice => "Chapter successfully deleted."
    else
      redirect_to :back, :notice => "Published chapters cannot be deleted.  Chapter was not deleted."      
    end
  end

  ################################################################
  
  def new_first_chapter
    # TODO need to ensure authentication and role before allowing a new story to be created
    @user = current_user
    @story = Story.find(params[:id])
    @first_chapter = @story.new_root_chapter(@user)
    @first_chapter.parent = nil
    if @first_chapter.save
      redirect_to edit_chapter_path( @first_chapter ), :notice => "Newly created opening chapter ready for editing."
    else
      redirect_to story_path( @story ), :error => "Unknown error in creating an opening chapter."
    end 
  end
  
end

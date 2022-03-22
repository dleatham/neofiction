class UsersController < ApplicationController
  
  # TODO decide if CanCan is needed in the user controller and ability class

  ################################################################
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end


  ################################################################
  def show
    @user = User.find(params[:id])
    @user.update_activity_score
    @user.update_popularity_score
    @created_groups = Group.where("user_id = ?", @user.id)
    @member_groups = @user.groups.all
    @memberships = @user.memberships.all
    @stories = @user.stories.all

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  ################################################################
  def edit
    @user = User.find(params[:id])
  end

  ################################################################
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        # TODO UserMailer.user_profile_updated(@user).deliver
        format.html { redirect_to(user_path(:user_id => @user.id), :notice => 'User Information was successfully updated.') }
        # format.html { redirect_to(profile_path, :notice => 'Profile Information was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

   ################################################################
   def profile
     # the following code is a hack to get around a bug I couldn't figure out - current_user was not reliably set/available
     # and sometimes self.current_user would cause a method not found error if there wasn't a logged in user.
     if self.respond_to?('current_user')
       if self.current_user == nil
         @the_current_user = User.new
       else
         @the_current_user = self.current_user
       end
     else
       @the_current_user = User.new
      end
                  
      # check to see if this is a request to view someone else's profile       
     if params[:id]
         @user = User.find(params[:id])
         if @the_current_user == @user
           @user_name = " You "
           @tracked_stories = @user.tracked_stories.limit(5)
           @tracked_chapters = @user.tracked_chapters.limit(5)
         else
           @user_name = @user.name
         end 
      # user viewing their own profile
      elsif current_user
        @user = @the_current_user
        @user_name = "You"
        # @tracked_stories = @user.tracked_stories.all
        # @tracked_chapters = @user.tracked_stories.all
        @tracked_stories = @user.tracked_stories.limit(5)
        @tracked_chapters = @user.tracked_chapters.limit(5)
        
      else
        flash[:error] = "The link to the profile page did not identify a user to view."        
        redirect_to(root_path)
      end     
       
      get_users_info
      
   end

   ################################################################
   def edit_profile
     @admin = false
     if (params[:id]) && ((current_user.role? "admin") || (current_user.role? "support"))
        @user = User.find(params[:id])
        @admin = true
      elsif current_user.id.to_s == params[:id]
        @user = current_user
      else
        flash[:error] = "A user profile can only be edited by that user while logged in."
        redirect_to(root_path)
      end
     
   end
   
   ################################################################
   def update_profile
     @user = User.find(params[:id])

     respond_to do |format|
       if @user.update_attributes(params[:user])
         # TODO UserMailer.user_profile_updated(@user).deliver
         format.html { redirect_to(user_profile_path(@user), :notice => 'User Information was successfully updated.') }
         format.xml  { head :ok }
       else
         format.html { render :action => "edit" }
         format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
       end
     end
     
   end
 
   ################################################################  
   def destroy
     @user = User.find(params[:id])
     @user.destroy

     respond_to do |format|
       format.html { redirect_to users_url }
       format.json { head :ok }
     end
   end
   
   ##################################################################
   def top_users
     User.all.each do |user|
       user.update_popularity_score
       user.update_activity_score
     end
     @most_popular = User.where("id > 2").order("popularity_score DESC")
     @most_active = User.where("id > 2").order("activity_score DESC")
     
   end
   
   ###################################################################
   def update_eula
     @user = current_user

     if params[:accept] == 'yes'
       @user.eula_agree = true
       #  assign the user an "author" role
       @user.roles_mask = 8
       notice_message = "License was accepted."
     else
       @user.eula_agree = false
       notice_message = "license was NOT accepted."
     end
     @user.save
     redirect_to :root, :notice => notice_message
   end
   
   
   private
   ###################################################################   
   def get_users_info
     # get unpublished/group items only if the user being viewed is the current_user
     if @user == current_user
       @unpublished_stories = @user.stories.where( "published = ?", false ).order("created_at DESC").page(params[:page]).per(10)
       @unpublished_chapters = @user.chapters.where( "published = ?", false ).order("created_at DESC").page(params[:page]).per(10)
       @created_groups = Group.where("user_id = ?", @user.id)
       @member_groups = @user.groups.all
       @memberships = @user.memberships.all
     else
       # current_user is viewing someone else, don't show unpublished/group items
       @unpublished_stories = []
       @unpublished_chapters = []
       @created_groups = []
       @member_groups = []
       @memberships = []
     end
     
     # the following are shown in all situations
     @stories = @user.stories.where( "published = ?", true ).accessible_by(current_ability).order("activity DESC").page(params[:page]).per(10)
     @chapters = @user.chapters.where( "published = ?", true ).accessible_by(current_ability).order("vote_cnt DESC").page(params[:page]).per(10)
     
     @user.update_activity_score
     @user.update_popularity_score
     
   end
   
   
   
end

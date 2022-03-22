class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
    current_user.authorize! :read, @groups    

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    current_user.authorize! :read, @group    
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @user = current_user
    @user_id = current_user.id
    @group = @user.groups.new
    current_user.authorize! :create, @group    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    current_user.authorize! :update, @group    
    @user_id = @group.user_id
    @memberships = @group.memberships.all
  end

  # POST /groups
  # POST /groups.json
  def create
    @user = current_user
    @user_id = @user.id
    @group = Group.new(params[:group])
    current_user.authorize! :create, @group    

    respond_to do |format|
      if @group.save
        #create the owner :membership
        membership = Membership.new( :user_id => @user.id, :group_id => @group.id, :group_role => "owner" )
        membership.save!
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @user = current_user
    @user_id = @user.id
    @group = Group.find(params[:id])
    current_user.authorize! :update, @group    

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    current_user.authorize! :destroy, @group    
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :ok }
    end
  end
end

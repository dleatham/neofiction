class MembershipsController < ApplicationController
  
  load_and_authorize_resource
  
  # GET /memberships
  # GET /memberships.json
  def index
    # cancan handling: @memberships = Membership.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @memberships }
    end
  end

  # GET /memberships/1
  # GET /memberships/1.json
  def show
    # cancan handling: @membership = Membership.find(params[:id])
    @group = Group.find(params[:group_id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @membership }
    end
  end

  # GET /memberships/new
  # GET /memberships/new.json
  def new
    # cancan handling: @membership = Membership.new
    @group = Group.find(params[:group_id])
    @membership.group_id = @group.id
    

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @membership }
    end
  end

  # GET /memberships/1/edit
  def edit
    # cancan handling: @membership = Membership.find(params[:id])
    @group = Group.find(params[:group_id])
  end

  # POST /memberships
  # POST /memberships.json
  def create
    # cancan handling: @membership = Membership.new(params[:membership])
    @group = Group.find(params[:group_id])
    @membership.group_id = @group.id

    respond_to do |format|
      if @membership.save
        format.html { redirect_to group_membership_path(@group, @membership), notice: 'Membership was successfully created.' }
        format.json { render json: @membership, status: :created, location: @membership }
      else
        format.html { render action: "new" }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /memberships/1
  # PUT /memberships/1.json
  def update
    # cancan handling: @membership = Membership.find(params[:id])
    @group = Group.find(params[:group_id])
    @membership.group_id = @group.id

    respond_to do |format|
      if @membership.update_attributes(params[:membership])
        format.html { redirect_to group_membership_path(@group, @membership), notice: 'Membership was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @membership.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /memberships/1
  # DELETE /memberships/1.json
  def destroy
    # cancan handling: @membership = Membership.find(params[:id])
    @group = @membership.group
    @membership.destroy

    respond_to do |format|
      format.html { redirect_to group_url( @group ) }
      format.json { head :ok }
    end
  end
end

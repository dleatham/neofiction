class GenresController < ApplicationController
  def index
    @genres = Genre.all_base_genre_sorted_by_total_stories
    current_user == nil ? @user = User.new : @user = current_user
    # @user.authorize! :read, Genre

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @genre }
    end
  end

  def show
    @genre = Genre.find(params[:id])
    current_user == nil ? @user = User.new : @user = current_user
    @user.authorize! :read, Genre
    @stories = @genre.stories.where( "published = ?", true ).accessible_by(current_ability).order("activity DESC").page(params[:page]).per(10)

    @genre_path = @genre.ancestors
    @genre_path << @genre
    @genre_path << @genre.children
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @genre }
    end
  end

  def new
    @genre = Genre.new
    current_user == nil ? @user = User.new : @user = current_user
    @user.authorize! :create, @genre   
    if params.include?( :parent_id )
      @parent_id = params[:parent_id]
      @genre.parent = Genre.find(params[:parent_id])
    else
      @parent_id = nil
      @genre.parent = nil
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @genre }
    end
  end

  def edit
    @genre = Genre.find(params[:id])
    current_user == nil ? @user = User.new : @user = current_user
    @user.authorize! :update, @genre    
    @genre.parent != nil ? @parent_id = @genre.parent.id : @parent_id = nil
  end

  def create
    @genre = Genre.new(params[:genre])
    current_user == nil ? @user = User.new : @user = current_user
    # @user.authorize! :create, Genre 
    raise AccessControlError unless @user.can? :create, Genre
    dog = "foobar"
    params[:genre][:parent_id] != "" ?  @genre.parent = Genre.find(params[:genre][:parent_id]) : @genre.parent = nil

    respond_to do |format|
      if @genre.save
        format.html { redirect_to @genre, notice: 'Genre was successfully created.' }
        format.json { render json: @genre, status: :created, location: @genre }
      else
        format.html { render action: "new" }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @genre = Genre.find(params[:id])
    current_user == nil ? @user = User.new : @user = current_user
    @user.authorize! :update, @genre    

    respond_to do |format|
      if @genre.update_attributes(params[:genre])
        format.html { redirect_to @genre, notice: 'Genre was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @genre.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @genre = Genre.find(params[:id])
    current_user == nil ? @user = User.new : @user = current_user
    @user.authorize! :destroy, @genre    
    @genre.destroy

    respond_to do |format|
      format.html { redirect_to genres_path }
      format.json { head :ok }
    end
  end



end


class TracksController < ApplicationController
  
  def create
        new_track = Track.new( :user_id => current_user.id,
                           :trackable_id => params[:trackable_id],
                           :trackable_type => params[:trackable_type])
    if new_track.save
      redirect_to :back, :notice  => "Now tracking this " + params[:trackable_type].downcase + "."
    else
      redirect_to :back, :notice => "Not able to track this " + params[:trackable_type].downcase + " due to an unexpected error."
    end
    
  end
  
  def destroy
    unwanted_track = Track.where("trackable_type = ? AND trackable_id = ? AND user_id = ?", 
               params[:trackable_type], params[:trackable_id], current_user.id).first
    if unwanted_track != nil
      unwanted_track.destroy
      redirect_to :back, :notice => "No longer traking this " + params[:trackable_type].downcase + "."
    else
      redirect_to :back, :notice => "Not able to stop tracking this " + params[:trackable_type].downcase + " due to an unexpected error."
    end
  end

end



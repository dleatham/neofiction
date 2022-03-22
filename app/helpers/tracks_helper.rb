module TracksHelper
  
  def track_options(user, trackable_object)
    content_tag :div do
      str = "<strong>" + trackable_object.class.name.upcase + " Tracking: </strong><br />&nbsp;&nbsp;&nbsp;&nbsp;"
      
      if user.tracking?(trackable_object)
        str += "You are tracking this " + trackable_object.class.name.downcase + ".  " + 
               link_to(" (stop tracking)", destroy_track_path(:trackable_id => trackable_object.id,
                                                             :trackable_type => trackable_object.class.name ))
      else  # user is not tracking the object
        str += link_to("Add this "  + trackable_object.class.name.downcase + " to your personal tracking list.", 
  	            add_track_path(:trackable_id => trackable_object.id, 
  	                          :trackable_type => trackable_object.class.name ))
      end
      raw(str)
    end
  end
end

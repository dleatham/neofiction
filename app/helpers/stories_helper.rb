module StoriesHelper
  
  def show_story_tree(nested_chapters)
    nested_chapters.map do |chapter, sub_chapters|
      # if (chapter is published) or (non-nil current user and the user/owner is viewing the chapter)
      if (chapter.published || (current_user && (current_user.id == chapter.user.id)) ) then content_tag(:li, 
                  # render( :partial => "chapters/chapter_node", :object => chapter) + content_tag(:ul, show_story_tree(sub_chapters), :class => "story_tree"),
                  # :class => "story_tree")
                  render( :partial => "chapters/chapter_node", :object => chapter) + content_tag(:ul, show_story_tree(sub_chapters)),
                  )
      end
    end.join.html_safe
  end 
  
end



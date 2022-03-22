require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  setup do
    # create/save a story associated with a user
     @user = users(:user_01)
     @user.save
     sign_in( :user, @user ) 
     @story = stories(:one)
     @story.user_id = @user.id
     @story.save
  end
  
  test "Story handling methods" do
    get( :index, :user_id => @user.id )
    assert_response( :success )
    assert_select "table" # table is displayed
    assert_select 'td', @story.title # title is displayed the table
    
    get( :all_stories )
    assert_response( :success )
    assert_select "table" # table is displayed
    assert_select 'td', @story.title # title is displayed in the table
    
    get( :a_story, :id => @story.id )
    assert_response( :success )
    assert_select( "p", "Title: " + @story.title)  # title is in a paragraph

    get( :show, :id => @story.id, :user_id => @user.id )
    assert_response( :success )
    assert_select( "p", "Title: " + @story.title) # title is in a paragraph
    
    # TODO Debug get() path erroro for :new action in stories controller
    # get( new_user-story_path, @user )
    # assert_response( :success )
    
   # TODO after debugging :new action, need to implement :create, :edit, and :destroy
    
  end
  
end

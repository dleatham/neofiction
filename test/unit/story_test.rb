require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user_01)
    @user.save  # need a .id
    @teststory = stories(:one)
    @title = @teststory.title 
    @teststory.user_id = @user.id
  end
  
  test "Load, save, and retrieve a Story record" do
    assert(@teststory.save)
    found = Story.where(:title => @title ).first
    assert_equal(@teststory, found)
  end
  
  test "Retrieve a Story record via User association" do
    @teststory.save
    found = @user.stories.where(:title => @title).first
    assert_equal(@teststory, found)
  end
  
end

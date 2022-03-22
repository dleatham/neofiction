require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "View/edit a profile" do
    # make sure we have a valid, logged-in user for the tests
    testuser = users(:user_01)
    assert(testuser.valid?)
    assert(testuser.save)
    assert( sign_in( :user, testuser ) )
    
    #logged in user should be able to see and edit their own profile
    get :profile
    assert_response( :success )
    get :profile, :user_id => testuser.id
    assert_response :success
    get :edit_profile
    assert_response( :success )
    
    # logged out user should not be able to see a profile unless a user_id is provided
    a_user_id = testuser.id
    sign_out testuser
    get :profile
    assert_response :redirect 
    get :profile, :user_id => a_user_id
    assert_response :success
    
    # only a logged in user can edit a profile, and then only their own
    get :edit_profile
    assert_response :redirect
  end
end

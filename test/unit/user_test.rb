
require 'test_helper'

class UserTest < ActiveSupport::TestCase

    ##########################################################
    test "Catch miss-matched passwords" do
      user = User.new(:email => 'test01@test.com', 
                      :password => "testtest", 
                     :password_confirmation => "nottesttest" )    
      assert(!user.valid?)
      assert(!user.save)
    end
    
    ##########################################################
    test "Check user can be saved/recalled" do 
      user = User.new(:email => 'test02@test.com', 
                      :password => "testtest", 
                      :password_confirmation => "testtest" )
      assert(user.valid?)
      user.save
      found = User.where(:email => 'test02@test.com').first
      assert_equal(user, found)      
    end
end
    

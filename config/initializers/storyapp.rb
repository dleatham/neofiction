# Be sure to restart your server when you modify this file.
#

############################################################
# It is necessary that the DB contain a single default/public
# group with :id = 1.  This is to support public/private groups
# through StoryApp's implementation of CanCan

# begin
  
  # confirm the group exists with a "find"
#  group = Group.find( Group::DEFAULTGROUPID )
# rescue
  # the group did not exist, so create it
#  group = Group.new
#  group.id = Group::DEFAULTGROUPID
#  group.title = "Public Group"
#  group.desc = "This group is the public (default) group in which all users, stories and chapters belong."
#  group.user_id = nil
#  group.save!
# end  
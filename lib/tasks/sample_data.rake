
#  to execute this script:  [storyapp] $ rake db:sample_data

BODY_TEXT = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante. Mauris mauris justo, lobortis quis elementum vel, gravida eget dui. Pellentesque at urna elit. Proin sagittis elit vitae mauris dignissim ac mattis."

namespace :db do
  desc "Fill database with sample data"
  task :sample_data => :environment do
    
    require 'faker'

    #reset the database to a blank state
    Rake::Task['db:reset'].invoke
    
    # create the default group
    
    group = Group.new
    group.id = Group::DEFAULTGROUPID
    group.title = "Public Group"
    group.desc = "This group is the public (default) group in which all users, stories and chapters belong."
    group.user_id = nil
    group.save!
    
     # create an array of sample genres
     puts "creating genres...."
     GENRE_COUNT = 6
     my_genre = Array.new
     my_genre[0] = Genre.create!( :title => "Generic", 
                                  :desc => "A generic category for stories lacking a genre.")
     my_genre[1]  = Genre.create!( :title => "Fan Fiction", 
                                  :desc => "A wide range of fiction based on the writings of fans of popular works.")
     my_genre[2]  = Genre.create!( :title => "Classics Redone", 
                                  :desc => "Fiction that takes well-known classics a different direction.")
     my_genre[3]  = Genre.create!( :title => "Mysteries", 
                                 :desc => "Fiction focused on solving a wide range of mysteries.")
    my_genre[4]  = Genre.create!( :title => "Young Adult Literature", 
                                 :desc => "Designed for young adults - 12 years of age and older.")
     my_genre[5] = Genre.create!( :title => "Children's Literature", 
                                  :desc => "Designed for children up to 12 years of age.")


    puts "creating users..." + " >>" + Time.now.to_s

    # create an all-roles user
    User.create!(:name => "Don Leatham",
                 :email => "dleatham@leatham.org",
                 :password => "testtest",
                 :password_confirmation => "testtest",
                 :encrypted_password => "$2a$10$KcOZWKkLlVbPOidsnXbo6uFabdmEXnEYQ49guzQo9FXSd.glgSBuu",
                 :sign_in_count => 0,
                 :last_sign_in_at => "2011-11-26 18:49:28.584432",
                 :last_sign_in_ip => "127.0.0.1",
                 :created_at => "2011-11-26 01:13:48.513970",
                 :roles_mask => 31 )  #bit-wise equivalent of all roles
    User.create!(:name => "Administrator",
                 :email => "admin@test.com",
                 :password => "testtest",
                  :password_confirmation => "testtest",
                 :encrypted_password => "$2a$10$KcOZWKkLlVbPOidsnXbo6uFabdmEXnEYQ49guzQo9FXSd.glgSBuu",
                  :sign_in_count => 0,
                  :last_sign_in_at => "2011-11-26 18:49:28.584432",
                  :last_sign_in_ip => "127.0.0.1",
                  :created_at => "2011-11-26 01:13:48.513970",
                 :roles_mask => 31 )  #bit-wise equivalent of all roles
    
    # create standard users             
    USER_COUNT = 10
    USER_GROUP_COUNT = 3
    GROUP_MEMBERS_COUNT = USER_COUNT / 5
    USER_COUNT.times do |n|
      name  = Faker::Name.name
      email = "test#{n+1}@test.com"
      if n < (USER_COUNT/2) - 2  # take into account the all-roles user and one more, don't know why
        role = 4   
      else
        role = 8 
      end
      user = User.create!(:name => name,
                  :email => email,
                  :password => "testtest",
                  :password_confirmation => "testtest",
                  :encrypted_password => "$2a$10$KcOZWKkLlVbPOidsnXbo6uFabdmEXnEYQ49guzQo9FXSd.glgSBuu",
                  :sign_in_count => 0,
                  :last_sign_in_at => "2011-11-26 18:49:28.584432",
                  :last_sign_in_ip => "127.0.0.1",
                  :created_at => "2011-11-26 01:13:48.513970",
                  :eula_agree => true,
                  :roles_mask => role )
                  
      # create groups for "even" users
      if n.even?
        USER_GROUP_COUNT.times do |z|
          group_title = "Group created by: " + user.name + " [" + user.email + "]" + "--" + (z+1).to_s
          group_desc = "Description for " + group_title
          group = Group.new
          group.title = group_title
          group.desc = group_desc
          group.id = ((n+1)*(USER_GROUP_COUNT + 1)) + z
          group.save
          # group = Group.create!( :title => group_title, :desc => group_desc, :user_id => user.id )
          # add the user to the group
          Membership.create!( :user_id => user.id, :group_id => group.id, :group_role => "Group Owner" )
        end
      end
    end # USER_COUNT.times do - create standare users
    puts "...Done creating users"  + " >>" + Time.now.to_s
 
    puts "...creating Memberships"  + " >>" + Time.now.to_s
    #add some members to the groups
    Group.all.each do |group|
      if group.id != Group::DEFAULTGROUPID
        owner_id = group.memberships.first.user_id
        GROUP_MEMBERS_COUNT.times do |y|
          rand_user = User.find( rand( USER_COUNT ) + 3)
          if !group.member? rand_user
            Membership.create!( :user_id => rand_user.id, :group_id => group.id, :group_role => "Group Member")
          end
        end
      end
    end
    puts "...Done creating Memberships"  + " >>" + Time.now.to_s
    
     
    puts "...creating stories"  + " >>" + Time.now.to_s
    TEST_USERS_COUNT = USER_COUNT - 2  # don't create stories for admin or dleatham users
    STORY_COUNT_SEED = 5
    BRANCHES_SEED = 5
    STORY_DEPTH_SEED = 10
    VOTES_SEED = 20
    
    # build stories for each user
    TEST_USERS_COUNT.times do |h|
      user = User.find( h + 3 )
      puts "creating stories for " + user.name + "(" + h.to_s + ")" + Time.now.to_s
      # create stories for each user
      STORY_COUNT_SEED.times do |i|
        puts "createing story " + i.to_s + " for user " + h.to_s + "   " + Time.now.to_s
        a_genre = my_genre[ rand( GENRE_COUNT ) ]
        story_title = (i+1).to_s + ": Story Title"
        story_desc = i.to_s + ": Story Description"
        story_activity = rand( 30 )
        user_id = user.id
        story = Story.new
        story.title = story_title 
        story.desc = story_desc
        story.activity = story_activity
        story.user_id = user_id
        story.genre_id = a_genre.id
        story.published = true unless i.odd?
        groups_created_by_user = Group.where("user_id = ?", user_id)
        group_count = groups_created_by_user.count
        if group_count != 0  # if the user has groups they created
          # make the group private by making the group_id this non-public group
          if group_count == 1
            story.group_id = groups_created_by_user[1].id
          else
            puts "creating group_id.  group_count: " + group_count.to_s
            story.group_id = groups_created_by_user[ rand( group_count ) ].id
          end
        end
        story.save
        # create random # of first chapters for each story
        BRANCHES_SEED.times do |j|
          puts "creating chapters for story " + story.id.to_s + "(" + h.to_s + ")" + Time.now.to_s
          pub =  true
          heading = "Chapter Heading (this is a root chapter )"
          chapter = Chapter.new
          chapter.heading = heading 
          chapter.body = BODY_TEXT 
          chapter.notes = ""
          chapter.published = pub 
          chapter.user_id = user.id
          chapter.group_id = story.group_id
          chapter.save!
          chapter.notes = "Chapter Record ID:" + chapter.id.to_s 
          chapter.save!
          first_chapter = FirstChapter.new( :story_id => story.id, :chapter_id => chapter.id )
          first_chapter.save!
          
        end #  BRANCHES_SEED.times - create random # of first chapters
            
        story.chapters.each do |chpt|
          # create a sequence of single chapters, parent-to-child, establishing the "depth" of the story 
          root_chapter = chpt
          depth_chapter = chpt
          STORY_DEPTH_SEED.times do |k|
            puts "k= " + k.to_s + Time.now.to_s
            pub =  true
            heading = "Chapter Heading (core line from the root chapter)"
            ch = Chapter.new
            ch.heading = heading 
            ch.body = BODY_TEXT 
            ch.published = pub 
            ch.user_id = user.id
            ch.group_id = story.group_id
            ch.parent = depth_chapter
            ch.save!
            ch.notes = "Chapter Record ID:" + ch.id.to_s
            ch.save!
            depth_chapter = ch
          end # STORY_DEPTH_SEED.TIMES - create a random length of story
          
        end # story.capters.each do
      end # STORY_COUNT_SEED.times  - create a randome # of stories for each user
    end # TEST_USERS_COUNT.times - build stories for each user
    
    # randomly insert chapters into the tree
    RANDOM_SIBLING_COUNT = 500
    TOTAL_CHAPTER_RECORDS = 300
    RANDOM_SIBLING_COUNT.times do |m|
      puts "m= " + m.to_s + Time.now.to_s
      record_number = rand( TOTAL_CHAPTER_RECORDS ) + 1
      chapter = Chapter.find( record_number )
      if !(chapter == nil) && !chapter.is_root?
        pub =  true
        heading = "Chapter Heading (Randomly inserted into tree )"
        ch = Chapter.new
        ch.heading = heading 
        ch.body = BODY_TEXT 
        ch.notes = "Chapter notes: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante." 
        ch.published = pub 
        ch.user_id = rand( USER_COUNT ) + 3 # adjust for rand() starting at 0 and the first two admin users
        ch.parent = chapter.parent
        ch.group_id = chapter.story.group_id
        ch.save!
        ch.notes = "Chapter Record ID:" + ch.id.to_s
        ch.save!
      end # if !(chapter = nul) && !chapter.is_root?
    end # RANDOM_SIBLING_COUNT.times do |m|
    
    # create some comments attched to the stories
    COMMENT_COUNT = 4
    Story.all.each do |story|
      puts "creating comments for story:" + story.id.to_s
      COMMENT_COUNT.times do |i|
        puts "creating story comment: " + i.to_s
        title = "Comment on story: " + story.id.to_s + "  count = " + i.to_s
        body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
        group_id = story.group.id
        comment = story.comments.create!(:title => title, :body => body, :group_id => group_id )
        comment.parent = nil
        comment.save
        COMMENT_COUNT.times do |j|
          puts "creating story comment comment: " + j.to_s
          c_title = "Comment on comment: " + comment.id.to_s + "  count = " + j.to_s
          c_body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
          c_group_id = comment.group.id
          sub_comment = comment.comments.create!(:title => c_title, :body => c_body, :group_id => c_group_id )
          sub_comment.parent = comment
          sub_comment.save
          COMMENT_COUNT.times do |k|
            c_title = "Comment on comment: " + sub_comment.id.to_s + "  count = " + k.to_s
            c_body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
            c_group_id = sub_comment.group.id
            sub_sub_comment = sub_comment.comments.create!(:title => c_title, :body => c_body, :group_id => c_group_id )
            sub_sub_comment.parent = sub_comment
            sub_sub_comment.save
          end # COMMENT_COUNT.times do |k|
        end # COMMENT_COUNT.times do |j|
      end # COMMENT_COUNT.times do |i|
    end # Story.each do |story|
    
    # create some comments attached to chapters
    RANDOM_COMMENT_COUNT = 800
    TOTAL_CHAPTERS = 1300
    
    RANDOM_COMMENT_COUNT.times do |i|
      chapter = Chapter.find( rand(TOTAL_CHAPTERS) + 1 )
      puts "creating chapter comment: " + i.to_s
      title = "Comment on chapter: " + chapter.id.to_s + "  count = " + i.to_s
      body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
      group_id = chapter.group.id
      comment = chapter.comments.create!(:title => title, :body => body, :group_id => group_id )
      comment.parent = nil
      comment.save
      if i.even?
        puts "creating Chapter sub-comment: " + i.to_s
        c_title = "Comment on comment: " + comment.id.to_s + "  count = " + i.to_s
        c_body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
        c_group_id = comment.group.id
        sub_comment = comment.comments.create!(:title => c_title, :body => c_body, :group_id => group_id )
        sub_comment.parent = comment
        sub_comment.save
        if rand(10).even?
          c_title = "Comment on sub comment: " + sub_comment.id.to_s + "  count = " + i.to_s
          c_body = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent et odio a dolor mattis mollis nec vel ante."
          c_group_id = sub_comment.group.id
          sub_sub_comment = sub_comment.comments.create!(:title => c_title, :body => c_body, :group_id => group_id )
          sub_sub_comment.parent = sub_comment
          sub_sub_comment.save
        end # if rand(10).even?
      end # if i.even?
    end # RANDOM_COMMENT_COUNT.times do |i|
    
    # Have each user cast a bunch of votes for chapters
    RANDOM_VOTE_COUNT = (0.25 * TOTAL_CHAPTERS).to_i
    User.all.each do |u|
      puts "processing votes for user_id: " + u.id.to_s
      RANDOM_VOTE_COUNT.times do |i|
        chapter = Chapter.find( rand( TOTAL_CHAPTERS ) + 1 )
        puts "voting for chapter: " + chapter.id.to_s
        u.vote_for chapter unless u.voted_for?( chapter ) || u.voted_against?( chapter )
        if i.even?  # do half as many vote-downs
          chapter = Chapter.find( rand( TOTAL_CHAPTERS ) + 1 )
          puts "voting against chapter: " + chapter.id.to_s
          u.vote_against chapter unless u.voted_against?( chapter ) || u.voted_for?( chapter )
        end
      end # RANDOM_VOTE_COUNT.times do
    end # Users.each do |u|
    
    
  end  # task do
end  # namespace do
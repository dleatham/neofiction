Storyapp::Application.routes.draw do
  
  ################################################
  # static pages
  get "pages/home"
  get "pages/writers", :as => :writers
  get "pages/readers", :as => :readers
  get "pages/contact", :as => :contact
  get "pages/about", :as => :about
  get "pages/news", :as => :news
  get "pages/license"
  get "pages/newest", :as => :newest
  get "pages/active", :as => :active
  get "pages/terms_of_service", :as => :terms
  
  
  match "/add_track(.:format)" => "tracks#create", :as => :add_track
  match "/destroy_track(.:format)" => "tracks#destroy", :as => :destroy_track
  
  
  ################################################
  devise_for :users
  # this was used when using reCaptcha for authentication...
  # devise_for :users, :controllers => { :registrations => "registrations" }

  ################################################
  root :to => "pages#home"
  
  ################################################
  # genre related routes
  # match "/genre" => "genre#index"
  # match "/genre/show/:id(.:format)" => "genre#show", :as => :genre_show
  resources :genres
  # match "/genres" => "genre#index", :as => :genre
  # match "/genres/:id(.:format)" => "genre#show", :as => :genre
  # match "/genre" => "genre#index", :as => :genres
  # match "/genre/:id(.:format)" => "genre#show", :as => :genres
  
  
  ################################################  
  # user related routes
  match "/profile" => "users#profile"
  match "/profile/:id/(.:format)" => "users#profile", :as => :user_profile
  match "/edit_profile/:id(.:format)" => "users#edit_profile", :as => :user
  match "/edit_profile/" => "users#edit_profile"
  match "/update_profile/:id(.:format)" => "users#update_profile", :as => :update_profile

  match "/top_users" => "users#top_users"
  match "/update_eula" => "users#update_eula"
  
  ################################################  
  # :story related routes independent of @user
  match "/all_stories" => "stories#all_stories", :as => :all_stories
  match "/a_story/:id(.:format)"=> "stories#a_story", :as => :a_story
  match "/story/:id/update_comment(.:format)" => "stories#update_comment"
  # match "/story/:id/track(.:format)" => "tracks#create", :as => :track_story
  # match "/story/:id/untrack(.:format)" => "tracks#delete", :as => :untrack_story

  ################################################  
  # :chapter related routes independent of @user
  match "/story/:id/new_first_chapter" => "chapters#new_first_chapter", :as => :new_first_chapter
  match "/story/:id(.:format)/tree_view" => "stories#tree_view"
  match "/chapter/:id/new_chapter" => "chapters#new_chapter", :as => :new_chapter
  match "/chapter/:id/update_comment(.:format)" => "chapters#update_comment"
  match "/chapter/:id/vote_for(.:format)" => "chapters#vote_for", :as => :vote_for
  match "/chapter/:id/vote_against(.:format)" => "chapters#vote_against", :as => :vote_against
  match "/chapter/:id(.:format)" => "chapters#create_comment"
  
  
  ################################################  
  # :group related routes
  resources :groups do
    resources :memberships
  end
  
  resources :stories do
    resources :comments
  end
  resources :chapters do
    resources :comments
    # collection do
      # put :update_attribute_on_the_spot
      # get :get_attribute_on_the_spot
    # end
  end
  
  ################################################  
  # catch all for any unknown route
  match '*path' => 'pages#not_found'
  
end

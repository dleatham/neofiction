module SharedMethods

  ###################################################################################
  # Users that are tracking this trackable object (Story or Chapter)
  def trackers
    self.users.all
  end

end
class AddEulaAgreeToUser < ActiveRecord::Migration
  def change
    add_column :users, :eula_agree, :boolean,  :default => false
  end
end

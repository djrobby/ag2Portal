class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,
                  :created_by, :updated_by

  has_paper_trail

  scopify
end

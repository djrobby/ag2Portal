class Attachment < ActiveRecord::Base
  attr_accessible :avatar
  has_attached_file :avatar
end

class Bank < ActiveRecord::Base
  attr_accessible :code, :name, :swift
end

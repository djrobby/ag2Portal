class App < ActiveRecord::Base
  belongs_to :site
  attr_accessible :description, :icon_file, :name, :path, :pict_file, :site_id,
                  :created_by, :updated_by

  has_paper_trail

  validates :description, :presence => true
  validates :icon_file,   :presence => true
  validates :name,        :presence => true
  validates :path,        :presence => true
  validates :pict_file,   :presence => true
  validates :site_id,     :presence => true
  def to_label
    "#{name} (#{site.name})"
  end
end

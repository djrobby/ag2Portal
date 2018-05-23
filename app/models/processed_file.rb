class ProcessedFile < ActiveRecord::Base
  # CONSTANTS
  INPUT = 1
  OUTPUT = 2

  belongs_to :processed_file_type
  attr_accessible :filename, :processed_file_type_id, :flow, :created_by

  has_paper_trail

  validates :filename,            :presence => true
  validates :processed_file_type, :presence => true
  validates :flow,                :presence => true,
                                  :numericality => { :only_integer => true, :greater_than => 0, :less_than => 3 }

  # Scopes
  scope :by_name_and_type, -> f,t { where("filename = ? AND processed_file_type_id = ?", f, t) }

  def flow_label
    case flow
      when 1 then I18n.t('activerecord.attributes.processed_file.input')
      when 2 then I18n.t('activerecord.attributes.processed_file.output')
      else 'N/A'
    end
  end
end

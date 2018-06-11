class ProcessedFile < ActiveRecord::Base
  include ModelsModule
  # CONSTANTS
  INPUT = 1
  OUTPUT = 2

  belongs_to :processed_file_type
  attr_accessible :filename, :processed_file_type_id, :flow, :created_by, :fileid, :filedate

  has_many :processed_file_items, dependent: :destroy

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

  #
  # CSV
  #
  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [array[0].sanitize(I18n.t("activerecord.attributes.processed_file.file_id")),
                  array[0].sanitize(I18n.t("activerecord.attributes.processed_file.filename")),
                  array[0].sanitize(I18n.t("activerecord.attributes.processed_file.file_date")),
                  array[0].sanitize(I18n.t("activerecord.attributes.processed_file.processed_file_type")),
                  array[0].sanitize(I18n.t("activerecord.attributes.processed_file.flow")),
                  array[0].sanitize(I18n.t(:created_at)),
                  array[0].sanitize(I18n.t(:created_by))]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      ProcessedFile.uncached do
        array.find_each do |processed_file|
          csv << [  processed_file.fileid,
                    processed_file.filename,
                    processed_file.formatted_date(processed_file.filedate),
                    processed_file.processed_file_type.name,
                    processed_file.flow_label,
                    processed_file.formatted_timestamp(processed_file.created_at.utc.getlocal),
                    User.find(processed_file.created_by).email]
        end
      end
    end
  end
end

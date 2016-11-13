class Formality < ActiveRecord::Base
  belongs_to :formality_type
  attr_accessible :code, :name, :formality_type_id

  has_many :contracting_request_types

  has_paper_trail

  validates :code,                :presence => true,
                                  :length => { :is => 3 },
                                  :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                  :uniqueness => true
  validates :name,                :presence => true
  validates :formality_type,      :presence => true

  # Scopes
  scope :by_code, -> { order(:code) }
  #
  scope :belongs_to_type, -> type { where("formality_type_id = ?", type).by_code }

  before_validation :fields_to_uppercase
  before_destroy :check_for_dependent_records

  def fields_to_uppercase
    if !self.code.blank?
      self[:code].upcase!
    end
  end

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_code
    if !self.name.blank?
      full_name += " " + self.name[0,40]
    end
    full_name
  end

  searchable do
    text :code, :name
    string :code, :multiple => true   # Multiple search values accepted in one search (inverse_no_search)
    integer :formality_type_id
    string :sort_no do
      code
    end
  end

  private

  def check_for_dependent_records
    # Check for contracting request types
    if contracting_request_types.count > 0
      errors.add(:base, I18n.t('activerecord.models.formality.check_for_contracting_request_types'))
      return false
    end
  end
end

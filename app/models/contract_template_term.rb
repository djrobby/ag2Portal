class ContractTemplateTerm < ActiveRecord::Base
  # CONSTANTS
  CONSTANTS = {:GENERAL => 1, :PARTICULAR => 2 }

  belongs_to :contract_template

  attr_accessible :description, :term_type, :term_no, :contract_template_id

  has_paper_trail

  validates :term_no,       :presence => true,
                            :length => { :minimum => 1, :maximum => 4 },
                            :uniqueness => { :scope => [:contract_template_id, :term_type] }
  validates :description,   :presence => true
  validates :term_type,     :presence => true,
                            :numericality => { :only_integer => true, :greater_than => 0, :less_than => 3  }

  # Scopes
  scope :by_no, -> { order(:term_no) }
  scope :by_type_no, -> { order(:term_type, :term_no) }
  #
  scope :general_terms, -> { where("term_type = ?", ContractTemplateTerm::GENERAL).by_no }
  scope :particular_terms, -> { where("term_type = ?", ContractTemplateTerm::PARTICULAR).by_no }

  def partial_name
    self.description[0,50]
  end
end

class Complaint < ActiveRecord::Base
  belongs_to :complaint_class
  belongs_to :complaint_status
  belongs_to :client
  belongs_to :subscriber
  belongs_to :project
  attr_accessible :answer, :complaint_no, :description, :ending_at, :official_sheet, :remarks, :starting_at,
                  :complaint_class_id, :complaint_status_id, :client_id, :subscriber_id, :project_id

  has_many :complaint_documents, dependent: :destroy

  has_paper_trail

  validates :complaint_no,      :presence => true,
                                :length => { :is => 22 },
                                :format => { with: /\A[a-zA-Z\d]+\Z/, message: :code_invalid },
                                :uniqueness => { :scope => :project_id }
  validates :description,       :presence => true
  validates :complaint_class,   :presence => true
  validates :complaint_status,  :presence => true
  validates :project,           :presence => true
  validates :client,            :presence => true, :if => "subscriber.blank?"

  # Scopes
  scope :by_no, -> { order(:complaint_no) }
  #
  scope :belongs_to_class, -> p { where("complaint_class_id = ?", p).by_no }
  scope :belongs_to_status, -> p { where("complaint_status_id = ?", p).by_no }
  scope :belongs_to_project, -> p { where("project_id = ?", p).by_no }

  def to_label
    "#{full_name}"
  end

  def full_name
    full_name = full_no
    full_name += " " + summary
    full_name
  end

  def summary
    description.blank? ? "N/A" : description[0,40]
  end

  def full_no
    # Complaint no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    complaint_no.blank? ? "" : complaint_no[0..11] + '-' + complaint_no[12..15] + '-' + complaint_no[16..21]
  end
end

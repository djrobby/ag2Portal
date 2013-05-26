class Ticket < ActiveRecord::Base
  belongs_to :ticket_category
  belongs_to :ticket_priority
  belongs_to :ticket_status
  belongs_to :technician
  belongs_to :office
  attr_accessible :assign_at, :status_changed_at, :status_changed_message, :ticket_message, :ticket_subject,
                  :ticket_category_id, :ticket_priority_id, :ticket_status_id, :technician_id, :office_id,
                  :created_by, :updated_by
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/ticket.png"

  validates :ticket_subject,      :presence => true,
                                  :length => { :maximum => 20 }
  validates :ticket_message,      :presence => true
  validates :ticket_category_id,  :presence => true
  validates :ticket_priority_id,  :presence => true

  before_create :assign_default_status_and_office
  after_create :send_email

  searchable do
    text :ticket_message, :ticket_subject, :created_by
    integer :ticket_category_id
    integer :ticket_priority_id
    integer :ticket_status_id
    integer :technician_id
    integer :office_id
    integer :id
    time :created_at
    time :assign_at
    string :created_by
  end

  private

  def assign_default_status_and_office
    # Assign default status
    if self.ticket_status_id.blank?
      self.ticket_status_id = 1
    end
    # Assign office if possible
    if self.office_id.blank?
      user = User.find(self.created_by)
      if !user.nil?
        worker = Worker.find_by_user_id(user)
        if !worker.nil?
          self.office_id = worker.office_id
        end
      end
    end
  end

  def send_email
    # Send notification e-mail
    Notifier.ticket_created(self).deliver
  end
end

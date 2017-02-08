class Ticket < ActiveRecord::Base
  belongs_to :ticket_category
  belongs_to :ticket_priority
  belongs_to :ticket_status
  belongs_to :technician
  belongs_to :office
  belongs_to :organization
  belongs_to :cc, class_name: 'User'
  attr_accessible :assign_at, :status_changed_at, :status_changed_message, :ticket_message, :ticket_subject,
                  :ticket_category_id, :ticket_priority_id, :ticket_status_id, :technician_id, :office_id,
                  :attachment, :created_by, :updated_by, :source_ip, :hd_email, :organization_id, :cc_id
  has_attached_file :attachment, :styles => { :medium => "192x192>", :small => "128x128>" }, :default_url => "/images/missing/:style/ticket.png"

  has_paper_trail

  validates :ticket_subject,          :presence => true,
                                      :length => { :maximum => 30 }
  validates :ticket_message,          :presence => true
  validates :ticket_category,         :presence => true
  validates :ticket_priority,         :presence => true
  validates :technician,              :presence => true, :if => :technician_required?
  validates :status_changed_message,  :presence => true, :if => :status_message_required?
  validates :organization,            :presence => true

  validates_attachment_content_type :attachment, :content_type => /\Aimage\/.*\Z/, :message => :attachment_invalid
  #validates_attachment_content_type :attachment, :content_type => [/\Aimage\/.*\Z/, 'application/pdf'], :message => :attachment_invalid
  #validates_attachment_content_type :attachment, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']

  before_create :assign_default_status_and_office
  after_create :send_create_email
  before_update :status_changed

  def short_ticket_message
    ticket_message.blank? ? '...' : (ticket_message.length>200 ? ticket_message[0,200]+'...' : ticket_message)
  end

  #
  # Class (self) user defined methods
  #
  def self.destinations
    destinations = []
    # loop thru existing tickets
    Ticket.all.each do |u|
      # check if destination already exists
      exists = false
      for i in 0...destinations.size
        if u.hd_email == destinations[i]
          exists = true
        end
      end
      if exists == false
        destinations = destinations << u.hd_email
      end
    end
    destinations
  end

  searchable do
    text :ticket_message, :ticket_subject, :created_by, :hd_email
    integer :ticket_category_id
    integer :ticket_priority_id
    integer :ticket_status_id
    integer :technician_id
    integer :office_id
    integer :id
    time :created_at
    time :assign_at
    string :created_by
    integer :organization_id
    string :hd_email
  end

  private

  def technician_required?
    if !self.ticket_status_id.blank? && self.ticket_status_id > 1
      true
    else
      false
    end
  end

  def status_message_required?
    if !self.ticket_status_id.blank? && self.ticket_status_id > 3
      true
    else
      false
    end
  end

  def assign_default_status_and_office
    # Assign default status
    if self.ticket_status_id.blank?
      self.ticket_status_id = 1
    end
    # Assign default office if possible
    if self.office_id.blank?
      user = User.find(self.created_by)
      if !user.nil?
        worker = Worker.find_by_user_id(user)
        if !worker.nil?
          self.office_id = worker.worker_items.first.office_id if worker.worker_items.count > 0
        end
      end
    end
  end

  def status_changed
    if self.ticket_status_id_was != self.ticket_status_id
      # Status forwarded to start/end task
      if self.ticket_status_id > 1 && self.assign_at.blank?
        self.assign_at = Time.now
        # Ticket has been assigned: Notify technician if it's not over
        if self.ticket_status_id < 4 && !self.technician.blank?
          Notifier.ticket_assigned(self).deliver
        end
      end
      # Status reverted to initial
      if self.ticket_status_id <= 1
        self.assign_at = nil
        if !self.technician.blank?
          self.technician = nil
        end
        if !self.status_changed_message.blank?
          self.status_changed_message = nil
        end
      end
      # Status changed
      self.status_changed_at = Time.now
      # Send notification e-mail
      Notifier.ticket_updated(self).deliver
    end
  end

  def send_create_email
    # Send notification e-mail
    Notifier.ticket_created(self).deliver
  end

  def send_update_email
    # Send notification e-mail
    Notifier.ticket_updated(self).deliver
  end
end

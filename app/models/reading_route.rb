class ReadingRoute < ActiveRecord::Base
  belongs_to :project
  belongs_to :office

  alias_attribute :route_code, :routing_code
  attr_accessible :name, :routing_code, :project_id, :office_id, :route_code

  has_many :subscribers
  has_many :pre_readings
  has_many :readings
  has_many :service_points
  has_many :water_supply_contracts

  has_paper_trail

  validates :route_code,  :presence => true
  validates :office_id,   :presence => true

  before_create :assign_code_office

  def assign_code_office
    self.routing_code = next_rr(office_id || project.office_id)
  end

  def to_label
    "#{route_code} (#{name})"
  end

  private

  def next_rr(office)
    code = ''
    office = office.to_i
    office_code = office.to_s.rjust(4, '0')
    last_code = ReadingRoute.select{|r| r.office_id == office}.max_by(&:routing_code).try(:routing_code)
    if last_code.nil?
      code = office_code + '000001'
    else
      last_code = last_code[4..9].to_i + 10
      code = office_code + last_code.to_s.rjust(6, '0')
    end
    code
  end
end

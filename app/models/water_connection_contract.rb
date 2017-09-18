class WaterConnectionContract < ActiveRecord::Base
  belongs_to :contracting_request
  belongs_to :water_connection_type
  belongs_to :client
  belongs_to :work_order
  belongs_to :sale_offer
  belongs_to :tariff
  belongs_to :bill
  belongs_to :caliber
  belongs_to :tariff_type
  belongs_to :service_point_purpose

  attr_accessible :contract_date, :remarks, :contracting_request_id, :water_connection_type_id,
                  :client_id, :work_order_id, :sale_offer_id, :tariff_id, :bill_id, :contract_no,
                  :caliber_id, :tariff_type_id, :service_point_purpose_id, :cadastral_reference,
                  :gis_id, :min_pressure, :max_pressure, :connections_no, :dwellings_no, :premises_no,
                  :common_items_no, :premises_area, :yard_area, :pipe_length, :pool_area, :diameter,
                  :created_by, :updated_by

  attr_accessible :water_connection_contract_items_attributes

  has_many :water_connection_contract_items, dependent: :destroy

  # Nested attributes
  accepts_nested_attributes_for :water_connection_contract_items,
                                :reject_if => :all_blank,
                                :allow_destroy => true

  has_paper_trail

  # validates
  validates_associated :water_connection_contract_items

  # methods
  def to_sale_offer
    sale_offer = SaleOffer.create(
      organization_id: contracting_request.project.organization.id,
      project_id: contracting_request.project_id,
      offer_no: sale_offer_next_no(contracting_request.project),
      offer_date: contracting_request.request_date,
      sale_offer_status_id: 3,
      client_id: client_id,
      contracting_request_id: contracting_request_id,
      payment_method_id: contracting_request.client.active_bank_account ? 6 : 1
    )
  end

  def full_no
    # Contract no (Project Id & Request type Id & year & sequential number) => PPPPPP-TT-YYYY-NNNNNN
    contract_no.blank? ? "" : contract_no[0..5] + '-' + contract_no[6..7] + '-' + contract_no[8..11] + '-' + contract_no[12..17]
  end

  def request_no
    contracting_request.request_no unless contracting_request.blank?
  end

  def flow
    water_connection_contract_items.reject(&:marked_for_destruction?).sum(&:quantity_flow)
  end

  def connection_price
    _a = "26.69".to_f
    _a *= (!diameter.blank? && diameter > 0) ? diameter : caliber.caliber
    _b = flow != 0 ? "182.28".to_f * flow : "182.28".to_f
    _a + _b
  end

  searchable do
    integer :id
    integer :contracting_request_id
    integer :caliber_id
    date :contract_date
    string :request_no do
      request_no
    end
  end

  private

    # Sale offer no
  def sale_offer_next_no(project)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    project_code = Project.find(project).project_code rescue '$'
    if project_code == '$'
      code = '$err'
    else
      project = project_code.rjust(12, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = SaleOffer.where("offer_no LIKE ?", "#{project}#{year}%").order(:offer_no).maximum(:offer_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

end

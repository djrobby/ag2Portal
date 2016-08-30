class Reading < ActiveRecord::Base
  belongs_to :project
  belongs_to :billing_period
  belongs_to :billing_frequency
  belongs_to :reading_type
  belongs_to :meter
  belongs_to :subscriber
  belongs_to :reading_route
  attr_accessible :reading_date, :reading_index, :reading_sequence, :reading_variant,
                  :project_id, :billing_period_id, :billing_frequency_id, :reading_type_id,
                  :meter_id, :subscriber_id, :reading_route_id

  has_many :reading_incidences
  has_and_belongs_to_many :reading_incidence_types, join_table: "reading_incidences"

  has_paper_trail

  validates :project,                       :presence => true
  validates :billing_period,                :presence => true
  validates :billing_frequency,             :presence => true
  validates :reading_type,                  :presence => true
  validates :meter,                         :presence => true
  validates :subscriber,                    :presence => true
  validates :reading_route,                 :presence => true
  validates :reading_date,                  :presence => true
  validates_numericality_of :reading_index, :only_integer => true,
                                            :greater_than_or_equal_to => 0,
                                            :message => :reading_invalid

  # Scopes
  scope :by_date_asc, -> { order(:reading_date) }
  scope :by_date_desc, -> { order('reading_date desc') }

  def consumption
    unless reading_index_1.nil? or reading_index.nil?
      if reading_index_1 <= reading_index
        reading_index - reading_index_1
      else
        # vuelta de contador
        ((10 ** meter.meter_model.digits) - reading_index_1) + reading_index
      end
    else
      nil
    end
  end

  def price(tariff)
    aux = 0
    total = 0
    (1..8).each do |i|
      # if limit nil (last block) or limit > consumption
      if tariff.instance_eval("block#{i}_limit").nil? || tariff.instance_eval("block#{i}_limit") > consumption
        total = total + (((consumption || 0) - aux) * tariff.instance_eval("block#{i}_fee"))
        break
      else
        total = total + ((tariff.instance_eval("block#{i}_limit") - aux) * tariff.instance_eval("block#{i}_fee"))
        aux = tariff.instance_eval("block#{i}_limit")
      end
    end
    return total + tariff.fixed_fee
  end

  def generate_bill
    bill = Bill.create(project_id: subscriber.try(:contracting_request).try(:project_id),
                          invoice_status_id: 1, #Nestor
                          bill_no: bill_next_no(subscriber.try(:contracting_request).try(:project_id),),
                          bill_date: Date.today,
                          subscriber_id: subscriber_id,
                          reading_id: id)
    subscriber.tariff_scheme.tariffs_supply(meter.caliber_id).each do |tariffs_biller|
      invoice = Invoice.create(
        bill_id: bill.id,
        invoice_no: invoice_next_no(subscriber.try(:contracting_request).try(:project).try(:company_id)),
        invoice_date: Date.today,
        invoice_status_id: 1, #Nestor
        invoice_type_id: 1,
        tariff_scheme_id: subscriber.tariff_scheme.id,
        company_id: tariffs_biller[0]
      ) #Nestor
      tariffs_biller[1].each do |tariff|
        InvoiceItem.create(
          invoice_id: invoice.id,
          code: tariff.try(:billable_item).try(:billable_concept).try(:code),
          description: tariff.try(:billable_item).try(:billable_concept).try(:name),
          quantity: 1,
          price: price(tariff),
          tax_type_id: nil,
          discount_pct: tariff.try(:discount_pct_f),
          tariff_id: tariff.id)
      end
    end
    return bill
  end

  private

  # Bill no
  def bill_next_no(project)
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
      last_no = Bill.where("bill_no LIKE ?", "#{project}#{year}%").order(:bill_no).maximum(:bill_no)
      if last_no.nil?
        code = project + year + '000001'
      else
        last_no = last_no[16..21].to_i + 1
        code = project + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end

  def invoice_next_no(company)
    year = Time.new.year
    code = ''
    # Builds code, if possible
    company_code = Company.find(company).invoice_code rescue '$'
    if company_code == '$'
      code = '$err'
    else
      company = company_code.rjust(4, '0')
      year = year.to_s if year.is_a? Fixnum
      year = year.rjust(4, '0')
      last_no = Invoice.where("invoice_no LIKE ?", "#{company}#{year}%").order(:invoice_no).maximum(:invoice_no)
      if last_no.nil?
        code = company + year + '000001'
      else
        last_no = last_no[8..14].to_i + 1
        code = company + year + last_no.to_s.rjust(6, '0')
      end
    end
    code
  end
end

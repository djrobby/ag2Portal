# encoding: utf-8

class PreBill < ActiveRecord::Base
  include ModelsModule

  belongs_to :project
  belongs_to :invoice_status
  belongs_to :subscriber
  belongs_to :client
  belongs_to :street_type
  belongs_to :zipcode
  belongs_to :town
  belongs_to :province
  belongs_to :region
  belongs_to :country
  belongs_to :bill
  belongs_to :reading_1, :class_name => 'Reading' # Previous reading
  belongs_to :reading_2, :class_name => 'Reading' # Current reading

  attr_accessible :bill_date, :bill_no, :first_name, :last_name, :company, :fiscal_id,
                  :project_id, :invoice_status_id, :subscriber_id, :client_id,
                  :street_type_id, :zipcode_id, :town_id, :province_id, :region_id, :country_id,
                  :bill_id, :confirmation_date,
                  :pre_group_no, :street_name, :street_number, :building, :floor, :floor_office, :created_by, :updated_by,
                  :reading_1_id, :reading_2_id

  has_many :pre_invoices, dependent: :destroy
  has_many :pre_invoice_items, through: :pre_invoices
  has_one :water_supply_contract
  has_many :client_payments

  def total_by_concept(billable_concept=1, includes_cf=false)
    if includes_cf
      pre_invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ?', billable_concept.to_i).sum(&:amount)
    else
      pre_invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ? AND subcode != "CF"', billable_concept.to_i).sum(&:amount)
    end
  end

  def total_by_concept_ff(billable_concept=1)
    pre_invoice_items.joins(tariff: :billable_item).where('billable_items.billable_concept_id = ? AND subcode = "CF"', billable_concept.to_i).sum(&:amount)
  end

  def reading
    reading_2
  end

  def bill_type
    pre_invoices.first.invoice_type rescue nil
    #reading.nil? ? "contratacion" : "suministro"
  end

  def full_no
    # Order no (Project code & year & sequential number) => PPPPPPPPPPPP-YYYY-NNNNNN
    if bill_no == "$err"
      "000000000000-000-00000"
    else
      #bill_no.blank? ? "" : bill_no[0..11] + '-' + bill_no[12..15] + '-' + bill_no[16..21]
    end
  end

  def total
    pre_invoices.reject(&:marked_for_destruction?).sum(&:total)
  end

  def subtotal
    pre_invoices.reject(&:marked_for_destruction?).sum(&:subtotal)
  end

  def net_tax
    pre_invoices.reject(&:marked_for_destruction?).sum(&:net_tax)
  end

  # Aux methods for CSV
  def raw_number(_number, _d)
    formatted_number_without_delimiter(_number, _d)
  end

  def sanitize(s)
    !s.blank? ? sanitize_string(s.strip, true, true, true, false) : ''
  end

  #
  # Class (self) user defined methods
  #m3 registrados  m3 estimados  m3 otros  m3 facturado  Cons.Medio  Subtotal  Impuestos Total
  def self.to_csv(array,code=nil)
    attributes = ["Id " + array[0].sanitize(I18n.t("activerecord.models.bill.one")),
                  array[0].sanitize(I18n.t("activerecord.attributes.invoice.invoice_no")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.bill_date")),
                  array[0].sanitize(I18n.t("ag2_gest.bills.index.payday_limit")),
                  array[0].sanitize(I18n.t("activerecord.attributes.report.billing_period")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.subscriber_code2")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.subscriber")),
                  array[0].sanitize(I18n.t("activerecord.attributes.subscriber.meter")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.lec_ant")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reading_date") + " "  + I18n.t("activerecord.attributes.reading.lec_ant")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.lec_act")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reading_date") + " "  + I18n.t("activerecord.attributes.reading.lec_act")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.reg")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.est")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.other")),
                  array[0].sanitize(I18n.t("activerecord.attributes.reading.fac")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.subtotal")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.taxes")),
                  array[0].sanitize(I18n.t("activerecord.attributes.bill.total"))]
                  code.each do |c|
                    attributes << c.code.to_s + " " +  "CF"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "CF"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "CF"
                    attributes << c.code.to_s + " " + "CV"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "CV"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "CV"
                    attributes << c.code.to_s + " " + "VP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "VP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "VP"
                    attributes << c.code.to_s + " " + "FP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "FP"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "FP"
                    attributes << c.code.to_s + " " + "BL1"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL1"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL1"
                    attributes << c.code.to_s + " " + "BL2"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL2"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL2"
                    attributes << c.code.to_s + " " + "BL3"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL3"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL3"
                    attributes << c.code.to_s + " " + "BL4"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL4"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL4"
                    attributes << c.code.to_s + " " + "BL5"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL5"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL5"
                    attributes << c.code.to_s + " " + "BL6"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL6"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL6"
                    attributes << c.code.to_s + " " + "BL7"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL7"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL7"
                    attributes << c.code.to_s + " " + "BL8"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.quantity_c") + "BL8"
                    attributes << c.code.to_s + " " + I18n.t("activerecord.attributes.bill.amount_c") + "BL8"
                  end

    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |b|
        bill = Bill.find(b.bill_id_) unless b.bill_id_.blank?
        payday_limit = b.payday_limit_.strftime("%d/%m/%Y") unless b.payday_limit_.blank?
        csv_data = [  b.bill_id_.blank? ? b.b_id_ : b.bill_id_,
                  b.bill_id_.blank? ? b.pre_invoice_no_ : bill.try(:invoices).first.old_no_based_real_no,
                  b.invoice_date_.strftime("%d/%m/%Y"),
                  b.bill_id_.blank? ? payday_limit : bill.try(:invoices).first.try(:payday_limit).strftime("%d/%m/%Y"),
                  b.billing_period_,
                  b.full_code_,
                  b.full_name_,
                  b.meter_code_,
                  b.reading_1_index_,
                  b.reading_1_date_,
                  b.reading_2_index_,
                  b.reading_2_date_,
                  b.consumption_real_,
                  b.consumption_estimated_,
                  b.consumption_other_,
                  b.consumption_,
                  b.raw_number(PreInvoice.find(b.p_id_).subtotal, 4),
                  b.raw_number(PreInvoice.find(b.p_id_).net_tax, 4),
                  b.raw_number(b.totals_, 4)]
        code.each do |c|
        data2 = [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil]
          PreInvoiceItem.where('pre_invoice_id = ?',b.p_id_).each do |i|
            if c.code == i.code
              quantity_ = i.quantity.blank? ? nil : b.raw_number(i.quantity, 2)
              amount_ = i.amount.blank? ? nil : b.raw_number(i.amount, 4)
              if i.code == "CON"
                data2[0] = i.measure.description
                data2[1] = quantity_
                data2[2] = amount_
              else
                if i.subcode == "CF"
                  data2[0] = i.measure.description
                  data2[1] = quantity_
                  data2[2] = amount_
                end
                if i.subcode == "CV"
                  data2[3] = i.measure.description
                  data2[4] = quantity_
                  data2[5] = amount_
                end
                if i.subcode == "VP"
                  data2[6] = i.measure.description
                  data2[7] = quantity_
                  data2[8] = amount_
                end
                if i.subcode == "FP"
                  data2[9] = i.measure.description
                  data2[10] = quantity_
                  data2[11] = amount_
                end
                if i.subcode == "BL1"
                  data2[12] = i.measure.description
                  data2[13] = quantity_
                  data2[14] = amount_
                end
                if i.subcode == "BL2"
                  data2[15] = i.measure.description
                  data2[16] = quantity_
                  data2[17] = amount_
                end
                if i.subcode == "BL3"
                  data2[18] = i.measure.description
                  data2[19] = quantity_
                  data2[20] = amount_
                end
                if i.subcode == "BL4"
                  data2[21] = i.measure.description
                  data2[22] = quantity_
                  data2[23] = amount_
                end
                if i.subcode == "BL5"
                  data2[24] = i.measure.description
                  data2[25] = quantity_
                  data2[26] = amount_
                end
                if i.subcode == "BL6"
                  data2[27] = i.measure.description
                  data2[28] = quantity_
                  data2[29] = amount_
                end
                if i.subcode == "BL7"
                  data2[30] = i.measure.description
                  data2[31] = quantity_
                  data2[32] = amount_
                end
                if i.subcode == "BL8"
                  data2[33] = i.measure.description
                  data2[34] = quantity_
                  data2[35] = amount_
                end
              end
            end # if c.code == i.code
          end # PreInvoiceItem.where('pre_invoice_id = ?',b.p_id_).each do |i|
          csv_data += data2
        end # code.each do |c|
        csv << csv_data
      end #array.each do |b| #array.each do |b|
    end
  end


  # PreBill no
  def self.next_no
    code = ''
    # Builds code, if possible
    last_code = PreBill.order(:pre_group_no).maximum(:pre_group_no)
    if last_code.nil?
      code = 1
    else
      code = last_code + 1
    end
    code
  end
end

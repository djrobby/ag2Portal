class ProductValuedStockByCompany < ActiveRecord::Base
  belongs_to :store
  belongs_to :product_family
  belongs_to :product
  belongs_to :company
  attr_accessible :store_id, :store_name, :product_family_id, :family_code, :family_name,
                  :product_id, :product_code, :main_description, :average_price,
                  :initial, :current, :current_value,
                  :company_id, :company_name, :company_average_price, :company_current_value
  # Scopes
  scope :ordered_by_store_family, -> { order(:store_id, :family_code, :product_code) }
  #
  scope :belongs_to_company, -> company { where("company_id = ? OR company_id IS NULL", company).ordered_by_store_family }
  scope :belongs_to_company_stock, -> company { where("company_id = ? OR company_id IS NULL AND current != ?", company,"0.0000").ordered_by_store_family }
  #
  scope :belongs_to_company_store, -> company, store { belongs_to_company(company).where("store_id = ?", store).ordered_by_store_family }
  scope :belongs_to_company_family, -> company, family { belongs_to_company(company).where("product_family_id = ?", family).ordered_by_store_family }
  scope :belongs_to_company_product, -> company, product { belongs_to_company(company).where("product_id = ?", product).ordered_by_store_family }
  #
  scope :belongs_to_company_store_family, -> company, store, family { belongs_to_company_store(company, store).where("product_family_id = ?", family).ordered_by_store_family }
  scope :belongs_to_company_store_product, -> company, store, product { belongs_to_company_store(company, store).where("product_id = ?", product).ordered_by_store_family }
  scope :belongs_to_company_family_product, -> company, family, product { belongs_to_company_family(company, family).where("product_id = ?", product).ordered_by_store_family }
  #
  scope :belongs_to_store, -> store { where("store_id = ?", store).ordered_by_store_family }
  scope :belongs_to_family, -> family { where("product_family_id = ?",family).ordered_by_store_family }
  scope :belongs_to_product, -> product { where("product_id = ?", product).ordered_by_store_family }
  #
  scope :belongs_to_store_family, -> store, family { belongs_to_store(store).where("product_family_id = ?", family).ordered_by_store_family }
  scope :belongs_to_store_product, -> store, product { belongs_to_store(store).where("product_id = ?", product).ordered_by_store_family }
  scope :belongs_to_family_product, -> family, product { belongs_to_family(family).where("product_id = ?", product).ordered_by_store_family }
  # for current != 0.0000
  scope :belongs_to_company_store_stock, -> company, store { belongs_to_company(company).where("store_id = ? AND current != ?", store,"0.0000").ordered_by_store_family }
  scope :belongs_to_company_family_stock, -> company, family { belongs_to_company(company).where("product_family_id = ? AND current != ?", family,"0.0000").ordered_by_store_family }
  scope :belongs_to_company_product_stock, -> company, product { belongs_to_company(company).where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }
  #
  scope :belongs_to_company_store_family_stock, -> company, store, family { belongs_to_company_store(company, store).where("product_family_id = ? AND current != ?", family,"0.0000").ordered_by_store_family }
  scope :belongs_to_company_store_product_stock, -> company, store, product { belongs_to_company_store(company, store).where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }
  scope :belongs_to_company_family_product_stock, -> company, family, product { belongs_to_company_family(company, family).where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }
  #
  scope :belongs_to_store_stock, -> store { where("store_id = ? AND current != ?", store,"0.0000").ordered_by_store_family }
  scope :belongs_to_family_stock, -> family { where("product_family_id = ? AND current != ?", family,"0.0000").ordered_by_store_family }
  scope :belongs_to_product_stock, -> product { where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }
  #
  scope :belongs_to_store_family_stock, -> store, family { belongs_to_store(store).where("product_family_id = ? AND current != ?", family,"0.0000").ordered_by_store_family }
  scope :belongs_to_store_product_stock, -> store, product { belongs_to_store(store).where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }
  scope :belongs_to_family_product_stock, -> family, product { belongs_to_family(family).where("product_id = ? AND current != ?", product,"0.0000").ordered_by_store_family }

  #
  # Class (self) user defined methods
  #
  def self.to_csv(array)
    attributes = [  "Id" + " " + I18n.t("activerecord.models.company.one"),
                    I18n.t("activerecord.models.company.one"),
                    I18n.t("activerecord.attributes.stock.store"),
                    I18n.t("activerecord.attributes.product.family_code"),
                    I18n.t("activerecord.attributes.product.product_family"),
                    I18n.t("activerecord.attributes.product.product_code"),
                    I18n.t("activerecord.attributes.product.main_description"),
                    I18n.t("activerecord.attributes.stock.current"),
                    I18n.t("ag2_products.ag2_products_track.stock_report.average_price"),
                    I18n.t("ag2_products.ag2_products_track.stock_report.total_full"),
                    I18n.t("ag2_products.ag2_products_track.stock_company_report.company_average_price"),
                    I18n.t("ag2_products.ag2_products_track.stock_company_report.company_current_value")]
    col_sep = I18n.locale == :es ? ";" : ","
    CSV.generate(headers: true, col_sep: col_sep, row_sep: "\r\n") do |csv|
      csv << attributes
      array.each do |i|
        c001 = i.company.id
        c002 = i.company.name
        i001 = i.store_name
        i002 = i.product_family.family_code
        i003 = i.product_family.name
        i004 = i.product.full_code
        i005 = i.product.main_description
        i006 = i.current
        i007 = i.average_price
        i008 = i.current_value
        i009 = i.company_average_price
        i010 = i.company_current_value

        csv << [  c001,
                  c002,
                  i001,
                  i002,
                  i003,
                  i004,
                  i005,
                  i006,
                  i007,
                  i008,
                  i009,
                  i010]
      end
    end
  end
end

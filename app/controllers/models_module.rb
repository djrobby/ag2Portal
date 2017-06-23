module ModelsModule
  include ActionView::Helpers::NumberHelper

  #
  # Tax Breakdown
  #
  # Returns multidimensional array containing different tax type in each line
  # Net: Each line contains 5 elements: Id, Description, Tax %, Net amount & Net tax
  # Gross: Each line contains 5 elements: Id, Description, Tax %, Amount & Tax
  def global_tax_breakdown(items, is_net)
    tt = []
    # Only if items
    if items.count > 0
      # Store first tax type & initialize
      prev_tt_id = items.first.tax_type_id
      prev_tt_net_tax = 0
      prev_tt_net = 0
      tax_type = TaxType.find(prev_tt_id) rescue nil
      # Loop thru items, ordered by tax type
      items.order(:tax_type_id).each do |i|
        # if tax type changes
        if i.tax_type_id != prev_tt_id
          # Store previous tax type data
          tt = tt << [prev_tt_id, tax_type.nil? ? "" : tax_type.description, tax_type.nil? ? 0 : tax_type.tax, prev_tt_net, prev_tt_net_tax]
          # Store current tax type & initialize
          prev_tt_id = i.tax_type_id
          prev_tt_net_tax = 0
          prev_tt_net = 0
          tax_type = TaxType.find(prev_tt_id) rescue nil
        end
        # Add amounts (nets) while current tax type
        if is_net
          # Net (item discount applied)
          prev_tt_net_tax += i.net_tax
          prev_tt_net += i.net
        else
          # Gross (no item discount applied)
          prev_tt_net_tax += i.tax
          prev_tt_net += i.amount
        end
      end
      # Store last unsaved tax type data
      tt = tt << [prev_tt_id, tax_type.nil? ? "" : tax_type.description, tax_type.nil? ? 0 : tax_type.tax, prev_tt_net, prev_tt_net_tax]
    end
    tt
  end

  #
  # Formatting
  #
  def formatted_date(_date)
    _format = I18n.locale == :es ? "%d/%m/%Y" : "%m-%d-%Y"
    _date.strftime(_format)
  end
  def formatted_timestamp(_date)
    _format = I18n.locale == :es ? "%d/%m/%Y %H:%M:%S" : "%m-%d-%Y %H:%M:%S"
    _date.strftime(_format)
  end
  def formatted_time(_date)
    _format = I18n.locale == :es ? "%H:%M:%S" : "%H:%M:%S"
    _date.strftime(_format)
  end
  def formatted_number(_number, _decimals)
    _delimiter = I18n.locale == :es ? "." : ","
    number_with_precision(_number.round(_decimals), precision: _decimals, delimiter: _delimiter)
  end
  def formatted_number_without_delimiter(_number, _decimals)
    number_with_precision(_number.round(_decimals), precision: _decimals)
  end

  def sanitize_string(str, encode, latin, all, capitalized)
    if !str.blank?
      if encode
        # Change encode
        if str.encoding.name != "UTF-8"
          str = str.force_encoding('ISO-8859-1').encode('UTF-8')
        end
      end
      if latin
        # Replace offending latin symbols
        str = str.tr($alpha, $gamma)
      end
      if all
        # Replace all non ASCII symbols
        str = str.gsub(/[^0-9A-Za-z ,;.:-_!?@#%&]/, '')
      end
      if capitalized
        # Capitalize (must be apply with encode!)
        str = str.downcase
        str = str.tr($ucase, $lcase)
        str = str.titleize
      end
    end
    str
  end

  #
  # Family Breakdown
  #
  # Returns multidimensional array containing different product family in each line
  # Each line contains 5 elements: Family Id, max_orders_count, max_orders_sum, Quantity sum & Net amount sum
  # items must be joined with :product & ordered by :product_family_id
  def global_family_breakdown(items)
    pf = []
    # Only if items
    if items.count > 0
      # Store first family & initialize
      prev_pf_id = items.first.product.product_family_id
      prev_pf_quantity = 0
      prev_pf_net = 0
      product_family = ProductFamily.find(prev_pf_id) rescue nil
      # Loop thru items, previously ordered by product family
      items.each do |i|
        # if family changed
        if i.product.product_family_id != prev_pf_id
          # Store previous family data
          pf = pf << [prev_pf_id, product_family.nil? ? 0 : product_family.max_orders_count, product_family.nil? ? 0 : product_family.max_orders_sum, prev_pf_quantity, prev_pf_net]
          # Store current family & initialize
          prev_pf_id = i.product.product_family_id
          prev_pf_quantity = 0
          prev_pf_net = 0
          product_family = ProductFamily.find(prev_pf_id) rescue nil
        end
        # Add net amount & quantity while current family
        prev_pf_quantity += i.quantity
        prev_pf_net += i.net
      end
      # Store last unsaved family data
      pf = pf << [prev_pf_id, product_family.nil? ? 0 : product_family.max_orders_count, product_family.nil? ? 0 : product_family.max_orders_sum, prev_pf_quantity, prev_pf_net]
    end
    pf
  end

  #
  # Project Breakdown
  #
  # Returns multidimensional array containing different project in each line
  # Each line contains 5 elements: Project Id, max_order_total, max_order_price, Net amount sum by project & Item net price
  # items must be ordered by :project_id
  def global_project_breakdown(items)
    pf = []   # 4 items array
    a = []    # 5 items returning array
    # Only if items
    if items.count > 0
      # First: Sum net amounts
      # Store first project & initialize
      prev_pf_id = items.first.project_id
      prev_pf_net = 0
      project = Project.find(prev_pf_id) rescue nil
      # Loop thru items, previously ordered by project
      items.each do |i|
        # if project changed
        if i.project_id != prev_pf_id
          # Store previous project data
          pf = pf << [prev_pf_id, project.nil? ? 0 : project.max_order_total, project.nil? ? 0 : project.max_order_price, prev_pf_net]
          # Store current project & initialize
          prev_pf_id = i.project_id
          prev_pf_net = 0
          project = Project.find(prev_pf_id) rescue nil
        end
        # Add net amount while current project
        prev_pf_net += i.net
      end
      # Store last unsaved project data
      pf = pf << [prev_pf_id, project.nil? ? 0 : project.max_order_total, project.nil? ? 0 : project.max_order_price, prev_pf_net]

      # Second: Returning array with item prices
      items.each do |i|
        # Search project in pf
        d = pf.detect { |f| f[0] == i.project_id }
        # Add row to array
        a = a << [d[0], d[1], d[2], d[3], i.net_price]
      end
    end

    # Returns a
    a
  end

  #
  # Office Breakdown
  #
  # Returns multidimensional array containing different office in each line
  # Each line contains 5 elements: Office Id, max_order_total, max_order_price, Net amount sum by project & Item net price
  # items must be joined with :project & ordered by :office_id
  def global_office_breakdown(items)
    pf = []   # 4 items array
    a = []    # 5 items returning array
    # Only if items
    if items.count > 0
      # First: Sum net amounts
      # Store first office & initialize
      prev_pf_id = items.first.project.office_id
      prev_pf_net = 0
      office = Office.find(prev_pf_id) rescue nil
      # Loop thru items, previously ordered by office
      items.each do |i|
        # if office changed
        if i.project.office_id != prev_pf_id
          # Store previous office data
          pf = pf << [prev_pf_id, office.nil? ? 0 : office.max_order_total, office.nil? ? 0 : office.max_order_price, prev_pf_net]
          # Store current office & initialize
          prev_pf_id = i.project.office_id
          prev_pf_net = 0
          office = Office.find(prev_pf_id) rescue nil
        end
        # Add net amount while current office
        prev_pf_net += i.net
      end
      # Store last unsaved project data
      pf = pf << [prev_pf_id, office.nil? ? 0 : office.max_order_total, office.nil? ? 0 : office.max_order_price, prev_pf_net]

      # Second: Returning array with item prices
      items.each do |i|
        # Search office in pf
        d = pf.detect { |f| f[0] == i.project.office_id }
        # Add row to array
        a = a << [d[0], d[1], d[2], d[3], i.net_price]
      end
    end

    # Returns a
    a
  end

  #
  # Company Breakdown
  #
  # Returns multidimensional array containing different company in each line
  # Each line contains 5 elements: Company Id, max_order_total, max_order_price, Net amount sum by project & Item net price
  # items must be joined with :project & ordered by :company_id
  def global_company_breakdown(items)
    pf = []   # 4 items array
    a = []    # 5 items returning array
    # Only if items
    if items.count > 0
      # First: Sum net amounts
      # Store first office & initialize
      prev_pf_id = items.first.project.company_id
      prev_pf_net = 0
      company = Company.find(prev_pf_id) rescue nil
      # Loop thru items, previously ordered by office
      items.each do |i|
        # if company changed
        if i.project.company_id != prev_pf_id
          # Store previous office data
          pf = pf << [prev_pf_id, company.nil? ? 0 : company.max_order_total, company.nil? ? 0 : company.max_order_price, prev_pf_net]
          # Store current company & initialize
          prev_pf_id = i.project.company_id
          prev_pf_net = 0
          company = Company.find(prev_pf_id) rescue nil
        end
        # Add net amount while current company
        prev_pf_net += i.net
      end
      # Store last unsaved project data
      pf = pf << [prev_pf_id, company.nil? ? 0 : company.max_order_total, company.nil? ? 0 : company.max_order_price, prev_pf_net]

      # Second: Returning array with item prices
      items.each do |i|
        # Search office in pf
        d = pf.detect { |f| f[0] == i.project.company_id }
        # Add row to array
        a = a << [d[0], d[1], d[2], d[3], i.net_price]
      end
    end

    # Returns a
    a
  end

  #
  # Zone Breakdown
  #
  # Returns multidimensional array containing different zone in each line
  # Each line contains 5 elements: Zone Id, max_order_total, max_order_price, Net amount sum by project & Item net price
  # items must be joined with :project and :office & ordered by :zone_id
  def global_zone_breakdown(items)
    pf = []   # 4 items array
    a = []    # 5 items returning array
    # Only if items
    if items.count > 0
      # First: Sum net amounts
      # Store first zone & initialize
      prev_pf_id = items.first.project.office.zone_id
      prev_pf_net = 0
      zone = Zone.find(prev_pf_id) rescue nil
      # Loop thru items, previously ordered by office
      items.each do |i|
        # if zone changed
        if i.project.office.zone_id != prev_pf_id
          # Store previous zone data
          pf = pf << [prev_pf_id, zone.nil? ? 0 : zone.max_order_total, zone.nil? ? 0 : zone.max_order_price, prev_pf_net]
          # Store current zone & initialize
          prev_pf_id = i.project.office.zone_id
          prev_pf_net = 0
          zone = Zone.find(prev_pf_id) rescue nil
        end
        # Add net amount while current zone
        prev_pf_net += i.net
      end
      # Store last unsaved project data
      pf = pf << [prev_pf_id, zone.nil? ? 0 : zone.max_order_total, zone.nil? ? 0 : zone.max_order_price, prev_pf_net]

      # Second: Returning array with item prices
      items.each do |i|
        # Search zone in pf
        d = pf.detect { |f| f[0] == i.project.office.zone_id }
        # Add row to array
        a = a << [d[0], d[1], d[2], d[3], i.net_price]
      end
    end

    # Returns a
    a
  end
end

module ModelsModule
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
end

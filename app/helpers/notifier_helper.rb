module NotifierHelper
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
end

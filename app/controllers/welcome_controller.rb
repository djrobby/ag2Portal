class WelcomeController < ApplicationController
  def index
    render :layout => false
    init_oco
  end

  private

  def oco_grant_access(oco_table)
    if oco_table.count == 0
      # Grant access to all...
      return 0.to_s
    else
      # Grant access only to exclusive...
      aux = ''
      oco_table.each do |e|
        aux += e.id.to_s + ';'
      end
      aux.chop!
      return aux
    end
  end
end

class WelcomeController < ApplicationController
  def index
    render :layout => false
    
    #
    # OCO
    #
    session[:office] = 0
    session[:company] = 0
    session[:organization] = 0
    session[:exclusive_office] = false
    
    if user_signed_in?
      offices = current_user.offices              # O
      companies = current_user.companies          # C
      organizations = current_user.organizations  # O
      
      # Exclusive Office?
      if offices.count == 1
        session[:office] = offices.first.id
        session[:company] = offices.first.company.id
        session[:organization] = offices.first.company.organization.id
        session[:exclusive_office] = true
      else
        # Exclusive Company?
        if companies.count == 1
          session[:company] = companies.first.id
          session[:organization] = companies.first.organization.id
        else
          # Exclusive Organization?
          if organizations.count == 1
            session[:organization] = organizations.first.id
          end
        end
      end
    end    
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

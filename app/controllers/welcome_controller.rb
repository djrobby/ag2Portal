class WelcomeController < ApplicationController
  def index
    render :layout => false
    
    #
    # OCO
    #
    if user_signed_in?
      if !session[:office]
        session[:office] = '0'
        session[:exclusive_office] = false
      end
      if !session[:company]
        session[:company] = '0'
        session[:exclusive_company] = false
      end
      if !session[:organization]
        session[:organization] = '0'
        session[:exclusive_organization] = false
      end

      offices = current_user.offices              # O
      companies = current_user.companies          # C
      organizations = current_user.organizations  # O
      
      # Exclusive Office?
      if offices.count == 1
        session[:office] = offices.first.id
        session[:company] = offices.first.company.id
        session[:organization] = offices.first.company.organization.id
        session[:exclusive_office] = true
        session[:exclusive_company] = true
        session[:exclusive_organization] = true
      else
        # Exclusive Company?
        if companies.count == 1
          session[:company] = companies.first.id
          session[:organization] = companies.first.organization.id
          session[:exclusive_company] = true
          session[:exclusive_organization] = true
        else
          # Exclusive Organization?
          if organizations.count == 1
            session[:organization] = organizations.first.id
            session[:exclusive_organization] = true
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

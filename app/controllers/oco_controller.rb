class OcoController < ApplicationController
  # Update company & organization at view from office select
  def oco_company_organization_from_office
    company = 0
    organization = 0
    
    if params[:office] != '0'
      office = Office.find(params[:office])
      if !office.nil?
        company = office.company.id
        organization = office.company.organization.id
      end
    end

    @json_data = { "company_id" => company, "organization_id" => organization }

    respond_to do |format|
      format.html # oco_company_organization_from_office.html.erb does not exist! JSON only
      format.json { render json: @json_data }
    end
  end

  # Update organization at view from company select
  def oco_organization_from_company
    organization = 0

    if params[:company] != '0'
      company = Company.find(params[:company])
      if !company.nil?
        organization = company.organization.id
      end
    end

    @json_data = { "organization_id" => organization }

    respond_to do |format|
      format.html # oco_organization_from_company.html.erb does not exist! JSON only
      format.json { render json: @json_data }
    end
  end

  # Set session variables
  def oco_set_session
    session[:office] = params[:office]
    session[:company] = params[:company]
    session[:organization] = params[:organization]
    @json_data = { "set" => "ok" }

    respond_to do |format|
      format.html # oco_set_session.html.erb does not exist! JSON only
      format.json { render json: @json_data }
    end
  end
end

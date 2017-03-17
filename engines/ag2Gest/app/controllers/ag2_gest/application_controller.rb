module Ag2Gest
  class ApplicationController < ::ApplicationController
    mattr_accessor :reset_session_variables_for_filters

    layout 'layouts/application'

    def reset_session_variables_for_filters
      session[:search] = nil
      session[:letter] = nil
      session[:No] = nil
      session[:Subscriber] = nil
      session[:name] = nil
      session[:Type] = nil
      session[:Status] = nil
      session[:sub_office] = nil
      session[:WrkrOffice] = nil
      session[:sort] = nil
      session[:direction] = nil
      session[:ifilter] = nil
      session[:Period] = nil
      session[:Group] = nil
      session[:Project] = nil
      session[:Client] = nil
      session[:Operation] = nil
      session[:Biller] = nil
      session[:entity] = nil
      session[:Request] = nil
      session[:ReadingRoute] = nil
      session[:Meter] = nil
      session[:Order] = nil
      session[:Caliber] = nil
      session[:RequestType] = nil
      session[:RequestStatus] = nil
      session[:ClientInfo] = nil
      session[:ServicePoint] = nil
      session[:StreetName] = nil
      session[:Use] = nil
    end

    def current_projects
      if session[:office] != '0'
        _projects = Project.where(office_id: session[:office].to_i).order(:project_code)
      elsif session[:company] != '0'
        _projects = Project.where(company_id: session[:company].to_i).order(:project_code)
      else
        _projects = session[:organization] != '0' ? Project.where(organization_id: session[:organization].to_i).order(:project_code) : Project.order(:project_code)
      end
    end

    def current_projects_ids
      current_projects.pluck(:id)
    end

    def current_offices_ids
      if session[:office] != '0'
        _offices =  [session[:office]]
      elsif session[:company] != '0'
        _offices = Company.find(session[:company]).offices.map(&:id)
      else
        _offices = session[:organization] != '0' ? Organization.find(session[:organization]).companies.map(&:offices).flatten.map(&:id) : Office.pluck(:id)
      end
    end

    def current_offices
      if session[:office] != '0'
        _offices =  Office.where(id: session[:office])
      elsif session[:company] != '0'
        _offices = Company.find(session[:company]).offices
      else
        _offices = session[:organization] != '0' ? Organization.find(session[:organization]).companies.map(&:offices).flatten : Office.all
      end
    end
  end
end

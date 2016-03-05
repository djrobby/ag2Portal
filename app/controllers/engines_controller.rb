class EnginesController < ApplicationController
  #
  # Resetting module (engine) session variables for filters
  #
  def reset_filters
    # Shared
    session[:search] = nil
    session[:letter] = nil
    session[:sort] = nil
    session[:direction] = nil
    session[:ifilter] = nil
    session[:From] = nil
    session[:To] = nil
    session[:Type] = nil
    session[:No] = nil
    session[:Project] = nil
    session[:Order] = nil
    session[:Products] = nil
    session[:Suppliers] = nil
    session[:Status] = nil
    session[:WrkrCompany] = nil
    session[:WrkrOffice] = nil
    # Ag2Admin
    # ...
    # Ag2Directory
    session[:ContactType] = nil
    # Ag2Finance
    # ...
    # Ag2Gest
    # ...
    # Ag2HelpDesk
    session[:Id] = nil
    session[:User] = nil
    session[:OfficeT] = nil
    session[:Category] = nil
    session[:Priority] = nil
    session[:Technician] = nil
    session[:Domain] = nil
    # Ag2Human
    session[:Worker] = nil
    session[:Code] = nil
    # Ag2Products
    session[:Family] = nil
    session[:Store] = nil
    session[:Measure] = nil
    session[:Manufacturer] = nil
    session[:Tax] = nil
    session[:Client] = nil
    session[:Stores] = nil
    session[:Companies] = nil
    # Ag2Purchase
    session[:Supplier] = nil
    session[:Invoice] = nil
    # Ag2Tech
    session[:Period] = nil
    session[:Group] = nil

    render json: { result: session[:letter] }
  end
end

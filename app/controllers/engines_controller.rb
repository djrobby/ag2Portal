class EnginesController < ApplicationController
  #
  # Resetting module (engine) session variables for filters
  #
  def reset_filters
=begin
    session.delete[:search] if session[:search]
    session.delete[:letter] if session[:letter]
    session.delete[:No] if session[:No]
    session.delete[:Supplier] if session[:Supplier]
    session.delete[:Status] if session[:Status]
    session.delete[:Project] if session[:Project]
    session.delete[:Order] if session[:Order]
    session.delete[:Invoice] if session[:Invoice]
    session.delete[:Products] if session[:Products]
    session.delete[:Suppliers] if session[:Suppliers]
    session.delete[:sort] if session[:sort]
    session.delete[:direction] if session[:direction]
    session.delete[:ifilter] if session[:ifilter]
=end
    case params[:m]
    when "Ag2Admin"
      Ag2Admin::ApplicationController.reset_session_variables_for_filters
    when "Ag2Directory"
      Ag2Directory::ApplicationController.reset_session_variables_for_filters
    when "Ag2Finance"
      Ag2Finance::ApplicationController.reset_session_variables_for_filters
    when "Ag2Gest"
      Ag2Gest::ApplicationController.reset_session_variables_for_filters
    when "Ag2HelpDesk"
      Ag2HelpDesk::ApplicationController.reset_session_variables_for_filters
    when "Ag2Human"
      Ag2Human::ApplicationController.reset_session_variables_for_filters
    when "Ag2Products"
      Ag2Products::ApplicationController.reset_session_variables_for_filters
    when "Ag2Purchase"
      Ag2Purchase::ApplicationController.reset_session_variables_for_filters
    when "Ag2Tech"
      Ag2Tech::ApplicationController.reset_session_variables_for_filters
    end

    render json: { result: "filters" }
  end
end

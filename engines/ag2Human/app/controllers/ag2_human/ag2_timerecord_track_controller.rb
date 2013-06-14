require_dependency "ag2_human/application_controller"

module Ag2Human
  class Ag2TimerecordTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:worker_report, :office_report]

    # Worker report
    def worker_report
      worker = params[:worker]
      @from = params[:from]
      @to = params[:to]
      office = params[:office]
      code = params[:code]

      if worker.blank? || @from.blank? || @to.blank? 
        return
      end

      # Search worker
      @worker = Worker.find(worker)
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(#{worker}, '#{from}', '#{to}', 0);")
        @time_records = TimerecordReport.all
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "ag2TimeRecord_#{@worker.worker_code}_#{from}_#{to}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    # Office report
    def office_report
      worker = params[:worker]
      @from = params[:from]
      @to = params[:to]
      office = params[:office]
      code = params[:code]

      if office.blank? || @from.blank? || @to.blank? 
        return
      end

      # Search office
      @office = Office.find(office)
      # Format dates
      from = Time.parse(@from).strftime("%Y-%m-%d")
      to = Time.parse(@to).strftime("%Y-%m-%d")
      
      respond_to do |format|
        # Execute procedure and load aux table
        ActiveRecord::Base.connection.execute("CALL generate_timerecord_reports(0, '#{from}', '#{to}', #{office});")
        @time_records = TimerecordReport.all
        # Render PDF
        format.pdf { send_data render_to_string,
                     filename: "ag2TimeRecord_#{@office.office_code}_#{from}_#{to}.pdf",
                     type: 'application/pdf',
                     disposition: 'inline' }
      end
    end

    #
    # Default Methods
    #
    def index
      authorize! :update, TimeRecord
    end
  end
end

require_dependency "ag2_human/application_controller"

module Ag2Human
  class Ag2TimerecordTrackController < ApplicationController
    before_filter :authenticate_user!
    skip_load_and_authorize_resource :only => [:worker_report, :office_report]

    # Worker report
    def worker_report
      worker = params[:worker]
      from = params[:from]
      to = params[:to]
      office = params[:office]
      code = params[:code]

      if worker.blank? || from.blank? || to.blank? 
        return
      end

      @worker = Worker.find(worker)
      
      respond_to do |format|
        format.pdf { send_data render_to_string,
                     filename: "ag2TimeRecord_#{@worker.worker_code}_#{from}-#{to}.pdf",
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

      @worker = Worker.find(worker)
      @office = Office.find(office)
      
      respond_to do |format|
        format.pdf { send_data render_to_string,
                     filename: "ag2TimeRecord.pdf",
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

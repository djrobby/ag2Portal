require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class ImportController < ApplicationController
    def index
    end

    def data_import
      message = I18n.t("result_ok_message_html", :scope => :"ag2_directory.import.index")
      @json_data = { "DataImport" => message, "Result" => "OK" }

      @workers = Worker.all

      @workers.each do |worker|
        @contact = CorpContact.find_by_worker_id(worker)
        if @contact.nil?
          # Add new contact from worker
          @contact = CorpContact.new
          @contact.worker_id = worker.id
        end
        update_contact(@contact, worker)
        if !@contact.save
          message = I18n.t("result_error_message_html", :scope => :"ag2_directory.import.index")
          @json_data = { "DataImport" => message, "Result" => "ERROR" }
          break
        end
      end
      sleep 1
      render json: @json_data
    end

    def update_contact(contact, worker)
      contact.first_name = worker.first_name unless worker.first_name.nil?
      contact.last_name = worker.last_name unless worker.last_name.nil?
      contact.company_id = worker.company_id unless worker.company_id.nil?
      contact.office_id = worker.office_id unless worker.office_id.nil?
      contact.department_id = worker.department_id unless worker.department_id.nil?
      contact.position = worker.position unless worker.position.nil?
      contact.email = worker.email unless worker.email.nil?
      contact.corp_phone = worker.corp_phone unless worker.corp_phone.nil?
      contact.corp_extension = worker.corp_extension unless worker.corp_extension.nil?
      contact.corp_cellular_long = worker.corp_cellular_long unless worker.corp_cellular_long.nil?
      contact.corp_cellular_short = worker.corp_cellular_short unless worker.corp_cellular_short.nil?
      contact.avatar = worker.avatar unless worker.avatar.nil?
    end
  end
end

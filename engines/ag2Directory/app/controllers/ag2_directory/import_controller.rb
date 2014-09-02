require_dependency "ag2_directory/application_controller"

module Ag2Directory
  class ImportController < ApplicationController
    before_filter :authenticate_user!
    # load_and_authorize_resource :corp_contact
    skip_load_and_authorize_resource :only => :data_import

    def index
      authorize! :update, CorpContact   # Authorize only if current user can update CorpContact model
    end

    def data_import
      message = I18n.t("result_ok_message_html", :scope => :"ag2_directory.import.index")
      @json_data = { "DataImport" => message, "Result" => "OK" }

      @workers = Worker.all
      
      @workers.each do |worker|
        # Worker items
        #worker_items = worker.worker_items
        worker_items = worker.worker_items.where('ending_at IS NULL OR ending_at > ?', DateTime.now.to_date)
        if !worker_items.blank?
          # Contact already exists?
          @contact = CorpContact.find_by_worker_id(worker)
          if @contact.nil?
            # Add new contact from worker
            @contact = CorpContact.new
            @contact.worker_id = worker.id
          end
          # Proceed based on ending_at & is_contact
          if worker.ending_at.blank? && worker.is_contact
            # Update contact
            update_contact(@contact, worker, worker_items.first, worker_items.count)
            # Save contact
            if !@contact.save
              message = I18n.t("result_error_message_html", :scope => :"ag2_directory.import.index")
              @json_data = { "DataImport" => message, "Result" => "ERROR" }
              break
            end
          else
            # Delete contact
            if !@contact.destroy
              message = I18n.t("result_error_message_html", :scope => :"ag2_directory.import.index")
              @json_data = { "DataImport" => message, "Result" => "ERROR" }
              break
            end
          end
        end
      end
      # sleep 1
      render json: @json_data
    end

    def update_contact(contact, worker, worker_item, worker_items_count)
      # Worker data
      contact.organization_id = worker.organization_id unless worker.organization_id.nil?
      contact.first_name = worker.first_name unless worker.first_name.nil?
      contact.last_name = worker.last_name unless worker.last_name.nil?
      contact.email = worker.email unless worker.email.nil?
      contact.corp_phone = worker.corp_phone unless worker.corp_phone.nil?
      contact.corp_extension = worker.corp_extension unless worker.corp_extension.nil?
      contact.corp_cellular_long = worker.corp_cellular_long unless worker.corp_cellular_long.nil?
      contact.corp_cellular_short = worker.corp_cellular_short unless worker.corp_cellular_short.nil?
      if !worker.avatar.blank? && worker.avatar.exists?
        contact.avatar = worker.avatar
      end
      # Worker item data
      contact.company_id = worker_item.company_id unless worker_item.company_id.nil?
      contact.office_id = worker_item.office_id unless worker_item.office_id.nil?
      contact.department_id = worker_item.department_id unless worker_item.department_id.nil?
      contact.position = worker_item.position unless worker_item.position.nil?
      contact.worker_count = worker_items_count
    end
  end
end

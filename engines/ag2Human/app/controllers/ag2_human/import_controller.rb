require_dependency "ag2_human/application_controller"
require "dbf"

module Ag2Human
  class ImportController < ApplicationController
    def index
    end

    #
    # Import DBF files from external source
    #
    def data_import
      message = I18n.t("result_ok_message_html", :scope => :"ag2_human.import.index")
      @json_data = { "DataImport" => message, "Result" => "OK" }

      # Loop thru 'empresa.dbf' records
      data_import_config = DataImportConfig.find_by_name('workers')
      source = source_exist(data_import_config.source, nil)
      if source.nil?
        @json_data = { "DataImport" => message, "Result" => "ERROR" }
        render json: @json_data
        return
      end
      # Loop thru 'empresa' records
      empresa = DBF::Table.new(source + "empresa.dbf")
      empresa.each do |e|
        company = Company.find_by_fiscal_id(e.ccif)
        if !company.nil?
          # Loop thru 'trabaja.dbf' records for current 'empresa' record
          source = source_exist(data_import_config.source, e.ccodemp)
          if !source.nil?
            trabaja = DBF::Table.new(source + "trabaja.dbf")
            trabaja.each do |t|
              nomina_id = e.ccodemp + '-' + t.ccodtra
              worker = Worker.find_by_nomina_id(nomina_id)
              if worker.nil?
                # Add new worker from source
                #worker = Worker.new
                #worker.nomina_id = nomina_id
              end
              #update_worker(worker, t)
              #if !worker.save
              #  message = "Error: Workers Updater finished unexpectedly!".html_safe
              #  @json_data = { "DataImport" => message, "Result" => "ERROR" }
              #  break
              #end
            end
          end
        end
      end
      sleep 1
      render json: @json_data
    end

    def commented_code
=begin      
      # Copy 'empresa.dbf' file
      data_import_config = DataImportConfig.find_by_name('workers')
      source = source_exist(data_import_config.source, nil)
      if source.nil?
        @json_data = { "DataImport" => message, "Result" => "ERROR" }
        render json: @json_data
      end
      target = Rails.root.to_s + data_import_config.target
      create_target_dir(target)
      FileUtils.cp(Dir[source + 'empresa.dbf'], target)
      
      # Loop thru 'empresa' records
      empresa = DBF::Table.new(target + "empresa.dbf")
      empresa.each do |record|
        company = Company.find_by_fiscal_id(record.ccif)
        if !company.nil?
          # Copy 'trabaja.dbf' file for current 'empresa'
          source = source_exist(data_import_config.source, record.ccodemp)
          if !source.nil?
            target = Rails.root.to_s + data_import_config.target + 'Emp' + record.ccodemp + '/'
            create_target_dir(target)
            FileUtils.cp(Dir[source + 'trabaja.dbf'], target)
          end
        end
      end
      
      render json: @json_data

      @sources = Worker.all

      @sources.each do |source|
        @worker = Worker.find_by_worker_id(source)
        if @worker.nil?
          # Add new worker from source
          @worker = Worker.new
          @worker.worker_id = source.id
        end
        update_worker(@worker, source)
        if @worker.save
          message = "Error: Workers Updater finished unexpectedly!".html_safe
          @json_data = { "DataImport" => message, "Result" => "ERROR" }
          render json: @json_data
        end
      end
      sleep 1
      render json: @json_data
=end
    end

    def dir_exist(dir)
      if !File.exist?(dir) || !File.directory?(dir)
        return false
      else
        return true
      end
    end
    
    def source_exist(dir, emp)
      from = dir + 'Emp'
      if !emp.nil?
        from = from + emp
      end
      from += '/'
      if !dir_exist(from)
        from = dir + 'EMP'
        if !emp.nil?
          from = from + emp
        end
        from += '/'
        if !dir_exist(from)
          from = nil
        end
      end
      return from
    end
        
    def create_target_dir(dir)
      if !dir_exist(dir)
        FileUtils.mkdir(dir)
      end
    end
    
    def update_worker(worker, source)
      worker.first_name = source.first_name unless source.first_name.nil?
      worker.last_name = source.last_name unless source.last_name.nil?
      worker.company_id = source.company_id unless source.company_id.nil?
      worker.office_id = source.office_id unless source.office_id.nil?
      worker.department_id = source.department_id unless source.department_id.nil?
      worker.position = source.position unless source.position.nil?
      worker.email = source.email unless source.email.nil?
      worker.corp_phone = source.corp_phone unless source.corp_phone.nil?
      worker.corp_extension = source.corp_extension unless source.corp_extension.nil?
      worker.corp_cellular_long = source.corp_cellular_long unless source.corp_cellular_long.nil?
      worker.corp_cellular_short = source.corp_cellular_short unless source.corp_cellular_short.nil?
    end
  end
end

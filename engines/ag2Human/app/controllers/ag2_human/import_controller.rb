require_dependency "ag2_human/application_controller"
require "dbf"

module Ag2Human
  class ImportController < ApplicationController
    before_filter :authenticate_user!
    before_filter :set_defaults
    # load_and_authorize_resource :worker
    skip_load_and_authorize_resource :only => :data_import
    def index
      authorize! :update, Worker
    end

    #
    # Import DBF files from external source
    #
    def data_import
      message = I18n.t("result_ok_message_html", :scope => :"ag2_human.import.index")
      @json_data = { "DataImport" => message, "Result" => "OK" }

      # Read parameters from data import config
      data_import_config = DataImportConfig.find_by_name('workers')
      source = source_exist(data_import_config.source, nil)
      if source.nil?
        message = I18n.t("result_error_message_html", :scope => :"ag2_human.import.index")
        @json_data = { "DataImport" => message, "Result" => "ERROR" }
        render json: @json_data
        return
      end
      # Loop thru 'empresa' records
      empresa = DBF::Table.new(source + "empresa.dbf")
      empresa.each do |e|
        company = Company.find_by_fiscal_id(e.ccif)
        if !company.nil?
          # Loop thru 'trabaja.dbf' records for current 'empresa/company' record
          source = source_exist(data_import_config.source, e.ccodemp)
          if !source.nil?
            trabaja = DBF::Table.new(source + "trabaja.dbf")
            trabaja.each do |t|
              # Do not import worker with blank email or withdrawal date
              if t.cemail.blank? || !t.dfecbaj.blank?
                next
              end
              nomina_id = e.ccodemp + '-' + t.ccodtra
              worker = Worker.find_by_nomina_id(nomina_id)
              if worker.nil?
                # Add new worker from source
                # worker = Worker.new
                # worker.nomina_id = nomina_id
              end
              #update_worker(worker, t)
              if worker.user_id > 0
                #if !worker.save
                  # Error: Workers Updater finished unexpectedly!
                  #message = I18n.t("result_error_message_html", :scope => :"ag2_human.import.index")
                  #@json_data = { "DataImport" => message, "Result" => "ERROR" }
                  #break
                #end
              end
            end
          end
        end
      end
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

    def set_defaults
      @street_type = StreetType.first
      @company = Company.first
      @office = Office.find_by_company_id(@company)
      @department = Department.first
      @professional_group = ProfessionalGroup.first
      @contract_type = ContractType.first
      @collective_agreement = CollectiveAgreement.first
      @zipcode = Zipcode.first
      @worker_type = WorkerType.first
      @degree_type = DegreeType.first
    end

    def update_worker(worker, source)
      worker.first_name = source.cnomtra unless source.cnomtra.blank?
      worker.last_name = source.capetra unless source.capetra.blank?
      worker.fiscal_id = source.cdni unless source.cdni.blank?
      worker.borned_on = source.dfecnac unless source.dfecnac.blank?
      worker.street_type_id = @street_type.id unless @street_type.id.blank?
      worker.street_name = source.cdircen unless source.cdircen.blank?
      worker.street_number = source.cnumcen unless source.cnumcen.blank?
      worker.floor = source.cpiso unless source.cpiso.blank?
      worker.floor_office = source.cpuerta unless source.cpuerta.blank?
      worker.zipcode_id = @zipcode.id unless @zipcode.id.blank?
      worker.town_id = @zipcode.town_id unless @zipcode.town_id.blank?
      worker.province_id = @zipcode.province_id unless @zipcode.province_id.blank?
      worker.company_id = @company.id unless @company.id.nil?
      worker.office_id = @office.id unless @office.id.nil?
      worker.department_id = @department.id unless @department.id.nil?
      worker.professional_group_id = @professional_group.id unless @professional_group.id.nil?
      worker.position = source.cpuesto unless source.cpuesto.nil?
      worker.starting_at = source.dfecalta unless source.dfecalta.blank?
      worker.issue_starting_at = source.dfecini unless source.dfecini.blank?
      worker.gross_salary = source.nbruto unless source.nbruto.blank?
      worker.affiliation_id = source.cnumseg unless source.cnumseg.blank?
      worker.contribution_account_code = source.csubcta unless source.csubcta.blank?
      worker.own_phone = source.ctelefono unless source.ctelefono.blank?
      worker.contract_type_id = @contract_type.id unless @contract_type.id.nil?
      worker.collective_agreement_id = @collective_agreement.id unless @collective_agreement.id.nil?
      worker.collective_agreement_id = @collective_agreement.id unless @collective_agreement.id.nil?
      worker.worker_type_id = @worker_type.id unless @worker_type.id.nil?
      worker.degree_type_id = @degree_type.id unless @degree_type.id.nil?
      worker.worker_code = generate_worker_code(source.capetra, source.cnomtra)
      if !source.cemail.blank?
        worker.email = source.cemail
        worker.user_id = find_user_by_email(source.cemail)
      end
    end

    def generate_worker_code(lastname, firstname)
      code = ''
      lastname1 = lastname.split(" ").first
      lastname2 = lastname.split(" ").last

      # Builds code, if possible
      if !lastname1.blank? && lastname1.length > 1
        code += lastname1[0, 2]
      end
      if !lastname2.blank? && lastname2.length > 1
        code += lastname2[0, 2]
      end
      if !firstname.blank? && firstname.length > 0
        code += firstname[0, 1]
      end

      if code == ''
        code = 'LLNNF'
      else
        if code.length < 5
          code = code.ljust(5, '0')
        end
      end
      code.upcase!
      
      # Code must be unique
      s = 0
      w = Worker.find_by_worker_code(code)
      until w.nil?
        code = code[0, 5] + s.to_s
        s += 1
        w = Worker.find_by_worker_code(code)
      end
      
      return code
    end
    
    def find_user_by_email(email)
      user = User.find_by_email(email)
      if user.nil?
        return 0
      end
      return user.id
    end
  end
end

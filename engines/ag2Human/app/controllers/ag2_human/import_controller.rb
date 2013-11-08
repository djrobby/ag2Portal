# encoding: utf-8

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
        # Do not import deleted 'empresa'
        if e.nil?
          next
        end
        # Search linked office
        office = Office.find_by_nomina_id(e.ccodemp)
        if !office.nil?
          company = office.company
          # Loop thru 'trabaja.dbf' records for current 'empresa/company' record
          source = source_exist(data_import_config.source, e.ccodemp)
          if !source.nil?
            trabaja = DBF::Table.new(source + "trabaja.dbf")
            trabaja.each do |t|
              # Do not import deleted worker
              if t.nil?
                next
              end
              # Do not import worker with active withdrawal date
              if !t.dfecbaj.blank? && t.dfecbaj <= DateTime.now.to_date
                next
              end
              # Setup worker code (nomina_id) and go on
              new_worker = false
              nomina_id = e.ccodemp + '-' + t.ccodtra
              worker = Worker.find_by_nomina_id(nomina_id)
              if worker.nil?
                # Do not import new worker with blank email
                if t.cemail.blank?
                  next
                end
                # Add new worker from source
                new_worker = true
                worker = Worker.new
                worker.nomina_id = nomina_id
              end
              update_worker(worker, t, company, office, new_worker)
              if worker.user_id > 0
                if !worker.save
                  # Error: Workers Updater finished unexpectedly!
                  message = I18n.t("result_error_message_html", :scope => :"ag2_human.import.index")
                  @json_data = { "DataImport" => message, "Result" => "ERROR" }
                  break
                end
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
      #@company = Company.first
      #@office = Office.find_by_company_id(@company)
      @street_type = StreetType.first
      @department = Department.first
      @professional_group = ProfessionalGroup.first
      @contract_type = ContractType.first
      @collective_agreement = CollectiveAgreement.first
      @zipcode = Zipcode.first
      @worker_type = WorkerType.first
      @degree_type = DegreeType.first
    end

    def search_aux_data(source)
      # Street type
      if !source.ccodvia.blank?
        @street_type = StreetType.find_by_street_type_code(source.ccodvia)
        if @street_type.nil?
          @street_type = StreetType.first
        end
      end
      # ZIP code
      if !source.ccodpos.blank?
        @zipcode = Zipcode.find_by_zipcode(source.ccodpos)
        if @zipcode.nil?
          @zipcode = Zipcode.first
        end
      end

      pro_group = nil
      # Collective agreement
      if !source.ccodconv.blank?
        pro_group = source.ccodconv
        @collective_agreement = CollectiveAgreement.find_by_nomina_id(source.ccodconv)
        if @collective_agreement.nil?
          @collective_agreement = CollectiveAgreement.first
        end
      end
      # Professional group
      if !source.ccodcat.blank?
        pro_group = pro_group + '-' + source.ccodcat
        @professional_group = ProfessionalGroup.find_by_nomina_id(pro_group)
        if @professional_group.nil?
          @professional_group = ProfessionalGroup.first
        end
      end
      # Contract type
      if !source.ccodcon.blank?
        @contract_type = ContractType.find_by_nomina_id(source.ccodcon)
        if @contract_type.nil?
          @contract_type = ContractType.first
        end
      end
      # Degree type
      # Where is it in trabaja.dbf?
    end
    
    def update_worker(worker, source, company, office, new)
      # Look for auxiliary data (other tables)
      search_aux_data(source)
      if new
        #
        # Add new row data
        #
        # Init uw vars to generate worker_code
        first_name_uw = nil
        last_name_uw = nil
        first_name_uw = sanitize_string(source.cnomtra) unless source.cnomtra.blank?
        last_name_uw = sanitize_string(source.capetra) unless source.capetra.blank?
        #first_name_uw = source.cnomtra.gsub(/[^0-9A-Za-z ]/, '').titleize unless source.cnomtra.blank?
        #last_name_uw = source.capetra.gsub(/[^0-9A-Za-z ]/, '').titleize unless source.capetra.blank?
        # Assign data
        worker.first_name = first_name_uw.titleize unless first_name_uw.blank?
        worker.last_name = last_name_uw.titleize unless last_name_uw.blank?
        worker.fiscal_id = source.cdni unless source.cdni.blank?
        worker.borned_on = source.dfecnac unless source.dfecnac.blank?
        worker.street_type_id = @street_type.id unless @street_type.id.blank?
        worker.street_name = source.cdircen.gsub(/[^0-9A-Za-z ]/, '').titleize unless source.cdircen.blank?
        worker.street_number = source.cnumcen unless source.cnumcen.blank?
        worker.floor = source.cpiso unless source.cpiso.blank?
        worker.floor_office = source.cpuerta unless source.cpuerta.blank?
        worker.zipcode_id = @zipcode.id unless @zipcode.id.blank?
        worker.town_id = @zipcode.town_id unless @zipcode.town_id.blank?
        worker.province_id = @zipcode.province_id unless @zipcode.province_id.blank?
        worker.company_id = company.id unless company.id.blank?
        worker.office_id = office.id unless office.id.blank?
        worker.department_id = @department.id unless @department.id.blank?
        worker.professional_group_id = @professional_group.id unless @professional_group.id.blank?
        worker.starting_at = source.dfecalta unless source.dfecalta.blank?
        worker.issue_starting_at = source.dfecini unless source.dfecini.blank?
        worker.affiliation_id = source.cnumseg unless source.cnumseg.blank?
        worker.contribution_account_code = source.csubcta unless source.csubcta.blank?
        worker.own_phone = source.ctelefono unless source.ctelefono.blank?
        worker.contract_type_id = @contract_type.id unless @contract_type.id.blank?
        worker.collective_agreement_id = @collective_agreement.id unless @collective_agreement.id.blank?
        worker.worker_type_id = @worker_type.id unless @worker_type.id.blank?
        worker.degree_type_id = @degree_type.id unless @degree_type.id.blank?
        worker.position = source.cpuesto.gsub(/[^0-9A-Za-z ]/, '').titleize unless source.cpuesto.blank?
        worker.gross_salary = source.nbruto unless source.nbruto.blank?
        # Mandatory worker code
        if !first_name_uw.nil? && !last_name_uw.nil?
          worker.worker_code = generate_worker_code(first_name_uw, last_name_uw)
        end
        # Mandatory e-mail and user info
        if !source.cemail.blank?
          worker.email = source.cemail
          worker.user_id = find_user_by_email(source.cemail)
        end
        # Check out other mandatory default data
        if worker.fiscal_id.blank?
          worker.fiscal_id = worker.worker_code + "0000"
        end
        if worker.contribution_account_code.blank?
          worker.contribution_account_code = "no_existe"
        end
      else
        #
        # Update current row data (if applicable)
        #
        if !source.cnomtra.blank? && worker.first_name != source.cnomtra.gsub(/[^0-9A-Za-z ]/, '').titleize
          worker.first_name = source.cnomtra.gsub(/[^0-9A-Za-z ]/, '').titleize
        end
        if !source.capetra.blank? && worker.last_name != source.capetra.gsub(/[^0-9A-Za-z ]/, '').titleize
          worker.last_name = source.capetra.gsub(/[^0-9A-Za-z ]/, '').titleize
        end
        if !source.cdni.blank? && worker.fiscal_id != source.cdni
          worker.fiscal_id = source.cdni
        end
        if !source.dfecnac.blank? && worker.borned_on != source.dfecnac
          worker.borned_on = source.dfecnac
        end
        if !@street_type.id.blank? && worker.street_type_id != @street_type.id
          worker.street_type_id = @street_type.id
        end
        if !source.cdircen.blank? && worker.street_name != source.cdircen.gsub(/[^0-9A-Za-z ]/, '').titleize
          worker.street_name = source.cdircen.gsub(/[^0-9A-Za-z ]/, '').titleize
        end
        if !source.cnumcen.blank? && worker.street_number != source.cnumcen
          worker.street_number = source.cnumcen
        end
        if !source.cpiso.blank? && worker.floor != source.cpiso
          worker.floor = source.cpiso
        end
        if !source.cpuerta.blank? && worker.floor_office != source.cpuerta
          worker.floor_office = source.cpuerta
        end
        if !@zipcode.id.blank? && worker.zipcode_id != @zipcode.id
          worker.zipcode_id = @zipcode.id
          worker.town_id = @zipcode.town_id
          worker.province_id = @zipcode.province_id
        end
        #-- Current worker company and office, should not be updated
        #if !company.id.blank? && worker.company_id != company.id
        #  worker.company_id = company.id
        #end
        #if !office.id.blank? && worker.office_id != office.id
        #  worker.office_id = office.id
        #end
        #--
        if !@department.id.blank? && worker.department_id != @department.id
          worker.department_id = @department.id
        end
        if !@professional_group.id.blank? && worker.professional_group_id != @professional_group.id
          worker.professional_group_id = @professional_group.id
        end
        if !source.dfecalta.blank? && worker.starting_at != source.dfecalta
          worker.starting_at = source.dfecalta
        end
        if !source.dfecini.blank? && worker.issue_starting_at != source.dfecini
          worker.issue_starting_at = source.dfecini
        end
        if !source.cnumseg.blank? && worker.affiliation_id != source.cnumseg
          worker.affiliation_id = source.cnumseg
        end
        if !source.csubcta.blank? && worker.contribution_account_code != source.csubcta
          worker.contribution_account_code = source.csubcta
        end
        if !source.ctelefono.blank? && worker.own_phone != source.ctelefono
          worker.own_phone = source.ctelefono unless source.ctelefono.blank?
        end
        if !@contract_type.id.blank? && worker.contract_type_id != @contract_type.id
          worker.contract_type_id = @contract_type.id
        end
        if !@collective_agreement.id.blank? && worker.collective_agreement_id != @collective_agreement.id
          worker.collective_agreement_id = @collective_agreement.id
        end
        if !@degree_type.id.blank? && worker.degree_type_id != @degree_type.id
          worker.degree_type_id = @degree_type.id
        end
        if !source.cpuesto.blank? && worker.position != source.cpuesto.gsub(/[^0-9A-Za-z ]/, '').titleize
          worker.position = source.cpuesto.gsub(/[^0-9A-Za-z ]/, '').titleize
        end
        if !source.nbruto.blank? && worker.gross_salary != source.nbruto
          worker.gross_salary = source.nbruto
        end
      end
      # Reset default auxiliary data
      set_defaults
    end

    def sanitize_string(str)
      if !str.blank?
        str.tr('áéíóúñÁÉÍÓÚÑ', 'aeiounAEIOUN')
        str.gsub(/[^0-9A-Za-z ]/, '')
      else
        str
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

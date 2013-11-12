# encoding: utf-8

# Replaceable latin symbols UTF-8 = ASCII-8BIT (ISO-8859-1)
# Á = \xC1  á = \xE1
# É = \xC9  é = \xE9
# Í = \xCD  í = \xED
# Ó = \xD3  ó = \xF3
# Ú = \xDA  ú = \xFA
# Ü = \xDC  ü = \xFC
# Ñ = \xD1  ñ = \xF1
# Ç = \xC7  ç = \xE7
# ¿ = \xBF  ¡ = \xA1
# ª = \xAA  º = \xBA

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
      message = I18n.t("ag2_human.import.index.result_ok_message_html")
      @json_data = { "DataImport" => message, "Result" => "OK" }
      $alpha = "\xC1\xC9\xCD\xD3\xDA\xDC\xD1\xC7\xE1\xE9\xED\xF3\xFA\xFC\xF1\xE7\xBF\xA1\xAA\xBA".force_encoding('ISO-8859-1').encode('UTF-8')
      $gamma = 'AEIOUUNCaeiouunc?!ao'
      $ucase = "\xC1\xC9\xCD\xD3\xDA\xDC\xD1\xC7".force_encoding('ISO-8859-1').encode('UTF-8')
      $lcase = "\xE1\xE9\xED\xF3\xFA\xFC\xF1\xE7".force_encoding('ISO-8859-1').encode('UTF-8')
      $positions = "presidentedirectorjeferesponsablegerentetecnicoauxauxiliaradmadminadministrativoadministrativa"
      incidents = false
      message = ''

      # Read parameters from data import config
      data_import_config = DataImportConfig.find_by_name('workers')
      source = source_exist(data_import_config.source, nil)
      if source.nil?
        message = I18n.t("ag2_human.import.index.result_error_message_html")
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
            # Import account code
            cctagene = nil
            empnomi = DBF::Table.new(source + "empnomi.dbf")
            enf = empnomi.first
            if !enf.nil?
              cctagene = enf.cctagene
            end
            # Import workers
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
              worker = update_worker(worker, t, company, office, new_worker, cctagene)
              if worker.user_id > 0
                if !worker.save
                  # Error: Workers Updater finished unexpectedly!
                  incidents = true
                  message += "<br/>".html_safe + e.ccodemp + " - " + t.capetra + " " + t.cnomtra + " - " + t.cemail
                  #break   # Import cancelled at company level
                end
              end
            end
          end
        end
      end
      if incidents
        message = I18n.t("ag2_human.import.index.result_ok_with_error_message_html") + message
        @json_data = { "DataImport" => message, "Result" => "ERROR" }
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
      # Collective agreement
      pro_group = nil
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
      # Worker type
      cpuesto = ''
      if !source.cpuesto.blank?
        cpuesto = sanitize_string(source.cpuesto, true, false, false, false).split(" ").first.downcase
        if $positions.include? cpuesto
          # Empleado
          @worker_type = WorkerType.find_by_description('Empleado') 
        else
          # Operario
          @worker_type = WorkerType.find_by_description('Operario') 
        end
        if @worker_type.nil?
          @worker_type = WorkerType.first
        end
      end
      # Department
      if cpuesto != '' && @worker_type.description == 'Operario'
        @department = Department.find_by_code('PROD')
        if @department.nil?
          @department = Department.first
        end
      end
      # Degree type
      # Where is it in trabaja.dbf?
    end
    
    def update_worker(worker, source, company, office, new, cctagene)
      # Look for auxiliary data (other tables)
      search_aux_data(source)
      if new
        #
        # Add new row data
        #
        # Init vars to generate worker_code
        first_name_wc = nil
        last_name_wc = nil
        first_name_wc = sanitize_string(source.cnomtra, true, true, false, false) unless source.cnomtra.blank?
        last_name_wc = sanitize_string(source.capetra, true, true, false, false) unless source.capetra.blank?
        # Assign data
        worker.first_name = sanitize_string(source.cnomtra, true, false, false, true) unless source.cnomtra.blank?
        worker.last_name = sanitize_string(source.capetra, true, false, false, true) unless source.capetra.blank?
        worker.fiscal_id = sanitize_string(source.cdni, true, false, false, false) unless source.cdni.blank?
        worker.borned_on = source.dfecnac unless source.dfecnac.blank?
        worker.street_type_id = @street_type.id unless @street_type.id.blank?
        worker.street_name = sanitize_string(source.cdircen, true, false, false, true) unless source.cdircen.blank?
        worker.street_number = sanitize_string(source.cnumcen, true, false, false, false) unless source.cnumcen.blank?
        worker.floor = sanitize_string(source.cpiso, true, false, false, false) unless source.cpiso.blank?
        worker.floor_office = sanitize_string(source.cpuerta, true, false, false, false) unless source.cpuerta.blank?
        worker.zipcode_id = @zipcode.id unless @zipcode.id.blank?
        worker.town_id = @zipcode.town_id unless @zipcode.town_id.blank?
        worker.province_id = @zipcode.province_id unless @zipcode.province_id.blank?
        worker.company_id = company.id unless company.id.blank?
        worker.office_id = office.id unless office.id.blank?
        worker.department_id = @department.id unless @department.id.blank?
        worker.professional_group_id = @professional_group.id unless @professional_group.id.blank?
        worker.starting_at = source.dfecalta unless source.dfecalta.blank?
        worker.issue_starting_at = source.dfecini unless source.dfecini.blank?
        worker.affiliation_id = sanitize_string(source.cnumseg, true, false, false, false) unless source.cnumseg.blank?
        if !cctagene.nil?
          worker.contribution_account_code = sanitize_string(cctagene, true, false, false, false)
        else
          worker.contribution_account_code = sanitize_string(source.csubcta, true, false, false, false) unless source.csubcta.blank?
        end
        worker.own_phone = phone(source.cpretel, source.ctelefono)
        worker.contract_type_id = @contract_type.id unless @contract_type.id.blank?
        worker.collective_agreement_id = @collective_agreement.id unless @collective_agreement.id.blank?
        worker.worker_type_id = @worker_type.id unless @worker_type.id.blank?
        worker.degree_type_id = @degree_type.id unless @degree_type.id.blank?
        worker.position = sanitize_string(source.cpuesto, true, false, false, true) unless source.cpuesto.blank?
        worker.gross_salary = source.nbruto unless source.nbruto.blank?
        # Mandatory worker code
        if !first_name_wc.nil? && !last_name_wc.nil?
          worker.worker_code = generate_worker_code(last_name_wc, first_name_wc)
        end
        # Mandatory e-mail and user info
        if !source.cemail.blank?
          worker.email = source.cemail
          worker.user_id = find_user_by_email(source.cemail)
        end
      else
        #
        # Update current row data (if applicable)
        #
        #-- Current worker first and last name, should not be updated
        #if !source.cnomtra.blank? && worker.first_name != source.cnomtra.gsub(/[^0-9A-Za-z ]/, '').titleize
        #  worker.first_name = source.cnomtra.gsub(/[^0-9A-Za-z ]/, '').titleize
        #end
        #if !source.capetra.blank? && worker.last_name != source.capetra.gsub(/[^0-9A-Za-z ]/, '').titleize
        #  worker.last_name = source.capetra.gsub(/[^0-9A-Za-z ]/, '').titleize
        #end
        #--
        if !source.cdni.blank? && worker.fiscal_id != sanitize_string(source.cdni, true, false, false, false)
          worker.fiscal_id = sanitize_string(source.cdni, true, false, false, false)
        end
        if !source.dfecnac.blank? && worker.borned_on != source.dfecnac
          worker.borned_on = source.dfecnac
        end
        if !@street_type.id.blank? && worker.street_type_id != @street_type.id
          worker.street_type_id = @street_type.id
        end
        if !source.cdircen.blank? && worker.street_name != sanitize_string(source.cdircen, true, false, false, true)
          worker.street_name = sanitize_string(source.cdircen, true, false, false, true)
        end
        if !source.cnumcen.blank? && worker.street_number != sanitize_string(source.cnumcen, true, false, false, false)
          worker.street_number = sanitize_string(source.cnumcen, true, false, false, false)
        end
        if !source.cpiso.blank? && worker.floor != sanitize_string(source.cpiso, true, false, false, false)
          worker.floor = sanitize_string(source.cpiso, true, false, false, false)
        end
        if !source.cpuerta.blank? && worker.floor_office != sanitize_string(source.cpuerta, true, false, false, false)
          worker.floor_office = sanitize_string(source.cpuerta, true, false, false, false)
        end
        if !@zipcode.id.blank? && worker.zipcode_id != @zipcode.id
          worker.zipcode_id = @zipcode.id
          worker.town_id = @zipcode.town_id
          worker.province_id = @zipcode.province_id
        end
        #-- Current worker company, office, department, progroup, contract, cagreement, degree & position
        #-- should not be updated
        #if !company.id.blank? && worker.company_id != company.id
        #  worker.company_id = company.id
        #end
        #if !office.id.blank? && worker.office_id != office.id
        #  worker.office_id = office.id
        #end
        #--
        #if !@department.id.blank? && worker.department_id != @department.id
        #  worker.department_id = @department.id
        #end
        #if !@professional_group.id.blank? && worker.professional_group_id != @professional_group.id
        #  worker.professional_group_id = @professional_group.id
        #end
        #if !@contract_type.id.blank? && worker.contract_type_id != @contract_type.id
        #  worker.contract_type_id = @contract_type.id
        #end
        #if !@collective_agreement.id.blank? && worker.collective_agreement_id != @collective_agreement.id
        #  worker.collective_agreement_id = @collective_agreement.id
        #end
        #if !@degree_type.id.blank? && worker.degree_type_id != @degree_type.id
        #  worker.degree_type_id = @degree_type.id
        #end
        #if !source.cpuesto.blank? && worker.position != sanitize_string(source.cpuesto, true, false, false, true)
        #  worker.position = sanitize_string(source.cpuesto, true, false, false, true)
        #end
        if !source.dfecalta.blank? && worker.starting_at != source.dfecalta
          worker.starting_at = source.dfecalta
        end
        if !source.dfecini.blank? && worker.issue_starting_at != source.dfecini
          worker.issue_starting_at = source.dfecini
        end
        if !source.cnumseg.blank? && worker.affiliation_id != sanitize_string(source.cnumseg, true, false, false, false)
          worker.affiliation_id = sanitize_string(source.cnumseg, true, false, false, false)
        end
        if !cctagene.nil?
          if worker.contribution_account_code != sanitize_string(cctagene, true, false, false, false)
            worker.contribution_account_code = sanitize_string(cctagene, true, false, false, false)
          end
        else
          if !source.csubcta.blank? && worker.contribution_account_code != sanitize_string(source.csubcta, true, false, false, false)
            worker.contribution_account_code = sanitize_string(source.csubcta, true, false, false, false)
          end
        end
        if !source.ctelefono.blank? && worker.own_phone != phone(source.cpretel, source.ctelefono)
          worker.own_phone = phone(source.cpretel, source.ctelefono)
        end
        if !source.nbruto.blank? && worker.gross_salary != source.nbruto
          worker.gross_salary = source.nbruto
        end
      end
      # Check out other mandatory default data
      if worker.fiscal_id.blank?
        worker.fiscal_id = worker.worker_code + "0000"
      end
      if worker.contribution_account_code.blank?
        worker.contribution_account_code = "no_existe"
      end
      if worker.starting_at.blank? && !source.dfecini.blank?
        worker.starting_at = source.dfecini
      end
      if worker.issue_starting_at.blank? && !source.dfecalta.blank?
        worker.issue_starting_at = source.dfecalta
      end
      
      # Reset default auxiliary data
      set_defaults
      # Bye
      return worker
    end

    def sanitize_string(str, encode, latin, all, capitalized)
      if !str.blank?
        if encode
          # Change encode
          if str.encoding.name != "UTF-8"
            str = str.force_encoding('ISO-8859-1').encode('UTF-8')
          end
        end
        if latin
          # Replace offending latin symbols
          str = str.tr($alpha, $gamma)
        end
        if all
          # Replace all non ASCII symbols
          str = str.gsub(/[^0-9A-Za-z ,;.:-_!?@#%&]/, '')
        end
        if capitalized
          # Capitalize (must be apply with encode!)
          str = str.downcase
          str = str.tr($ucase, $lcase)
          str = str.titleize
        end
      end
      return str
    end
    
    def phone(pre, num)
      phone = ''
      if !pre.blank?
        pre = sanitize_string(pre, true, false, false, false)
        phone += pre
      end
      if !num.blank?
        num = sanitize_string(num, true, false, false, false)
        phone += num      
      end
      return phone
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
      
      # Code should be unique
      #s = 0
      #w = Worker.find_by_worker_code(code)
      #until w.nil?
      #  code = code[0, 5] + s.to_s
      #  s += 1
      #  w = Worker.find_by_worker_code(code)
      #end
      
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

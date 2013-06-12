class TimerecordReport < ActiveRecord::Base
  belongs_to :worker, :foreign_key => 'tr_worker_id'
  belongs_to :type1, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_1'
  belongs_to :type2, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_2'
  belongs_to :type3, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_3'
  belongs_to :type4, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_4'
  belongs_to :type5, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_5'
  belongs_to :type6, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_6'
  belongs_to :type7, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_7'
  belongs_to :type8, :class_name => 'TimerecordType', :foreign_key => 'tr_type_id_8'
  belongs_to :code1, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_1'
  belongs_to :code2, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_2'
  belongs_to :code3, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_3'
  belongs_to :code4, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_4'
  belongs_to :code5, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_5'
  belongs_to :code6, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_6'
  belongs_to :code7, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_7'
  belongs_to :code8, :class_name => 'TimerecordCode', :foreign_key => 'tr_code_id_8'

  attr_accessible :tr_code_id_1, :tr_code_id_2, :tr_code_id_3, :tr_code_id_4,
                  :tr_code_id_5, :tr_code_id_6, :tr_code_id_7, :tr_code_id_8,
                  :tr_date,
                  :tr_time_1, :tr_time_2, :tr_time_3, :tr_time_4,
                  :tr_time_5, :tr_time_6, :tr_time_7, :tr_time_8,
                  :tr_type_id_1, :tr_type_id_2, :tr_type_id_3, :tr_type_id_4,
                  :tr_type_id_5, :tr_type_id_6, :tr_type_id_7, :tr_type_id_8,
                  :tr_worker_id, :tr_worked_time, :tr_rec_count
end

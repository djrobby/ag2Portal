class TimerecordReport < ActiveRecord::Base
  belongs_to :worker, :foreign_key => 'tr_worker_id'

  attr_accessible :tr_code_id_1, :tr_code_id_2, :tr_code_id_3, :tr_code_id_4,
                  :tr_code_id_5, :tr_code_id_6, :tr_code_id_7, :tr_code_id_8,
                  :tr_date,
                  :tr_time_1, :tr_time_2, :tr_time_3, :tr_time_4,
                  :tr_time_5, :tr_time_6, :tr_time_7, :tr_time_8,
                  :tr_type_id_1, :tr_type_id_2, :tr_type_id_3, :tr_type_id_4,
                  :tr_type_id_5, :tr_type_id_6, :tr_type_id_7, :tr_type_id_8,
                  :tr_worker_id
end

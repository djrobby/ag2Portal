class CreateViewProductValuedStockByCompany < ActiveRecord::Migration
  def up
    execute 'create view product_valued_stock_by_companies as
    select `pvs`.`store_id` AS `store_id`,`pvs`.`store_name` AS `store_name`,`pvs`.`product_family_id` AS `product_family_id`,`pvs`.`family_code` AS `family_code`,`pvs`.`family_name` AS `family_name`,`pvs`.`product_id` AS `product_id`,`pvs`.`product_code` AS `product_code`,`pvs`.`main_description` AS `main_description`,`pvs`.`average_price` AS `average_price`,`pvs`.`initial` AS `initial`,`pvs`.`current` AS `current`,`pvs`.`current_value` AS `current_value`,`pcp`.`company_id` AS `company_id`,`pcp`.`average_price` AS `company_average_price`,cast(coalesce((`pvs`.`current` * `pcp`.`average_price`),0) as decimal(13,4)) AS `company_current_value` from (`product_valued_stocks` `pvs` left join `product_company_prices` `pcp` on((`pvs`.`product_id` = `pcp`.`product_id`)))'
  end

  def down
    execute 'drop view product_valued_stock_by_companies'
  end
end

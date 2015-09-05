class CreateViewProductFamilyStock < ActiveRecord::Migration
  def up
    execute 'create view product_family_stocks as 
    select `f`.`id` AS `product_family_id`,`f`.`family_code` AS `family_code`,`f`.`name` AS `family_name`,`s`.`store_id` AS `store_id`,`a`.`name` AS `store_name`,sum(`s`.`initial`) AS `initial`,sum(`s`.`current`) AS `current` from (`product_families` `f` join (`products` `p` join (`stocks` `s` join `stores` `a` on((`a`.`id` = `s`.`store_id`))) on((`s`.`product_id` = `p`.`id`))) on((`p`.`product_family_id` = `f`.`id`))) group by `f`.`id`,`s`.`store_id`'
  end

  def down
    execute 'drop view product_family_stocks'
  end
end

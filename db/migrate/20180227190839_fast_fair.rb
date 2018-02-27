class FastFair < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view fast_fair as
      select buy_currency, sell_currency,
      (max(case when side = 'buy' then price else null end) 
       + min(case when side = 'sell' then price else null end)) / 2 
       as fair
      from cleared_orders 
      group by buy_currency, sell_currency;
    SQL
  end

  def down
    execute 'drop view fast_fair;'
  end
end

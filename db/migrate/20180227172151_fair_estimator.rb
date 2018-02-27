class FairEstimator < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view fairs as
      select buy.buy_currency, buy.sell_currency,
      (max(buy.price) + min (sell.price)) / 2 as fair
      from cleared_orders buy
      inner join (
          select buy_currency, sell_currency,
          price
          from  cleared_orders
          where side = 'sell'
      ) sell
      on sell.buy_currency = buy.buy_currency
      and sell.sell_currency = buy.sell_currency
      where buy.side = 'buy'
      group by buy.buy_currency, buy.sell_currency;
    SQL
  end

  def down
    execute 'drop view fairs;'
  end
end

class ClearedOrders < ActiveRecord::Migration
  def up
    execute <<-SQL
      create view cleared_orders as
      --Highest bid/ask values per currency
      with price_extremes as (
          select buy_currency, sell_currency, max(bid) max_bid, min(ask) min_ask
          from (
              select buy_currency, sell_currency, 
              case when side = 'buy' then price else NULL end bid, 
              case when side = 'sell' then price else NULL end ask
              from orders
          ) labeled
          group by buy_currency, sell_currency
      ),
      
      --Orders which would have been (at least partially) cleared if we were all on one exchange
      overlapping_orders as (
          select 
          id, side, price, quantity, orders.buy_currency, orders.sell_currency,
          sum(quantity) over (partition by side, orders.buy_currency, orders.sell_currency order by price) as cumulative_quantity
          from orders 
          inner join price_extremes using (buy_currency, sell_currency)
          where 
          (side = 'buy' and price > price_extremes.min_ask or
          side = 'sell' and price < price_extremes.max_bid)
          order by cumulative_quantity
      ),
      
      --Counts of how many bids and asks should have been cleared
      overlap_statistics as (
          select buy_currency, sell_currency,
          max(case when side = 'buy' then cumulative_quantity else 0 end) maximum_bid_quantity,
          max(case when side = 'sell' then cumulative_quantity else 0 end) maximum_ask_quantity
          from overlapping_orders
          group by buy_currency, sell_currency
      ),
      
      /*
      Subtracts the opposite action. E.g., suppose there were 100 overlapping asks. Then we would have:
      
      price original_cumulative_quantity modified_cumulative_quantity
      1		10				-90
      2		60				-40
      3		150				50
      
      We can then discard the first two orders and consider the third one to have just been
      an order for 50
      */
      modified_overlapping_orders as (
          select *
          from (
              select id, side, price, buy_currency, sell_currency,
              case
                  when side = 'buy' then cumulative_quantity - maximum_ask_quantity
                  else cumulative_quantity - maximum_bid_quantity
              end quantity
              from overlapping_orders
              inner join overlap_statistics using (buy_currency, sell_currency)
          ) adjusted_quantities
          where quantity > 0
      ),
      
      --Orders which would not have been cleared if it was all one exchange
      not_overlapping_orders as (
          select *
          from orders
          where not exists (
            select 1
              from overlapping_orders
              where overlapping_orders.id = orders.id
          )
      )
      
      select id, side, price, quantity, buy_currency, sell_currency from not_overlapping_orders
      union 
      select id, side, price, quantity, buy_currency, sell_currency from modified_overlapping_orders;
    SQL
  end

  def down
    execute 'drop view cleared_orders;'
  end
end

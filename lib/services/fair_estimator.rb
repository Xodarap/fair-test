require 'services/order_book'


# Class which calculates the fair market value of everything
#
# Note: get_fairs_fast is the only function I would keep if this were real
class FairEstimator
  def get_fairs_ruby
    cleared_orders = create_book(Order.all)
    cleared_orders.get_fairs
  end

  def get_fairs_sql
    ActiveRecord::Base.connection.execute('select * from fairs').map do |fair|
      [[fair['buy_currency'],  fair['sell_currency']], fair['fair']]
    end.to_h
  end

  def get_fairs_hybrid
    bids, asks = ClearedOrder.all.sort_by(&:price)
      .partition { |order| order.side == 'buy' }
    OrderBook.new(bids, asks).get_fairs
  end

  def get_fairs_fast
    ActiveRecord::Base.connection.execute('select * from fast_fair').map do |fair|
      [[fair['buy_currency'],  fair['sell_currency']], fair['fair']]
    end.to_h
  end

  private
  def create_book(orders)
    bids, asks = orders.sort_by(&:price)
      .partition { |order| order.side == 'buy' }
    OrderBook.new(bids, asks)
  end
end
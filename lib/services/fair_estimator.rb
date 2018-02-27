require 'attr_extras'
class FairEstimator
  class OrderBook
    attr_initialize :bids, :asks

    def execute_or_add_bid(order)
      lowest_ask = @asks.first
      return add_bid(order) if lowest_ask.nil?
      return add_bid(order) if order.price < lowest_ask.price

      if order.quantity < lowest_ask.quantity
        lowest_ask.quantity -= order.quantity
      else
        order.quantity -= lowest_ask.quantity
        @asks.pop
        execute_or_add_bid(order)
      end
    end

    def get_fairs
      max_bids = group_and_get_extrema(@bids, :max)
      max_asks = group_and_get_extrema(@asks, :min)

      max_bids.map do |currency, bid_price|
        ask_price = max_asks[currency]
        [currency, (bid_price + ask_price)/2]
      end.to_h
    end

    private

    def add_bid(order)
      @bids = @bids.push(order)
    end

    def group_and_get_extrema(orders, extreme)
      orders.group_by do |order|
        [order.buy_currency, order.sell_currency]
      end.transform_values do |orders|
        orders.map(&:price).sort.send(extreme)
      end
    end
  end

  def get_fairs_ruby
    cleared_orders = create_book(Order.all)
    cleared_orders.get_fairs
  end

  def get_fairs_sql
    ActiveRecord::Base.connection.execute('select * from fairs').map do |fair|
      [[fair['buy_currency'],  fair['sell_currency']], fair['fair']]
    end.to_h
  end

  private
  def create_book(orders)
    bids, asks = orders.sort_by(&:price)
      .partition { |order| order.side == 'buy' }
    book = OrderBook.new([], asks)

    bids.reduce(book) do |book, order|
      book.execute_or_add_bid(order)
      book
    end
  end
end
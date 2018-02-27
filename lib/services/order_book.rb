require 'attr_extras'

# Helper class which maintains in order book and executes any relevant
# trades. The basic idea is that we start off with all of our asks, and
# then iteratively add bids, either by executing them against asks or
# just adding them to the list.
class OrderBook
  def initialize(bids, asks)
    @asks = asks.sort_by(&:price)
    @bids = []
    bids.each(&method(:execute_or_add_bid))
  end

  def execute_or_add_bid(order)
    lowest_ask = @asks.first
    return if order.quantity == 0
    return add_bid(order) if lowest_ask.nil?
    return add_bid(order) if order.price < lowest_ask.price

    if order.quantity < lowest_ask.quantity
      lowest_ask.quantity -= order.quantity
    else
      order.quantity -= lowest_ask.quantity
      @asks.shift
      execute_or_add_bid(order)
    end
  end

  def get_fairs
    max_bids = group_and_get_extrema(@bids, :max)
    max_asks = group_and_get_extrema(@asks, :min)

    max_bids.map do |currency, bid_price|
      ask_price = max_asks[currency]
      fair = if bid_price.nil?
        ask_price
      elsif ask_price.nil?
        bid_price
      else
        (bid_price + ask_price)/2
      end

      [currency, fair]
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
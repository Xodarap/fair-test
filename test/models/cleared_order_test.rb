require 'test_helper'
require 'pry'

class ClearedOrderTest < ActiveSupport::TestCase
  fixtures :all

  test 'correct count' do
    assert_equal 1, ClearedOrder.where(side: 'buy').count
    assert_equal 1, ClearedOrder.where(side: 'sell').count
  end

  test 'not overlapping orders' do
    orders = ActiveRecord::Base.connection.execute 'select * from not_overlapping_orders;'
    assert_equal 1, orders.count
  end

  test 'price extremes' do
    extremes = ActiveRecord::Base.connection.execute 'select * from price_extremes;'
    relevant = extremes[0]
    assert_equal '100', relevant['max_bid']
    assert_equal '90', relevant['min_ask']
  end

  test 'overlapping orders' do
    orders = ActiveRecord::Base.connection.execute 'select * from overlapping_orders;'
    assert_equal 4, orders.count
  end

  test 'overlap statistics' do
    orders = ActiveRecord::Base.connection.execute 'select * from overlap_statistics;'
    relevant = orders[0]
    assert_equal '20', relevant['maximum_bid_quantity']
    assert_equal '10', relevant['maximum_ask_quantity']
  end

  test 'modified overlapping orders' do
    orders = ActiveRecord::Base.connection.execute 'select * from modified_overlapping_orders;'
    assert_equal 1, orders.count
  end
end

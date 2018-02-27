require 'benchmark'
require 'services/fair_estimator'

estimator = FairEstimator.new
iterations = 1
ruby = 1
sql = 1
hybrid = 1
fast = 1
Benchmark.bm do |bm|
  bm.report('Ruby') { iterations.times { ruby = estimator.get_fairs_ruby } }
  # bm.report('Sql') { iterations.times { sql = estimator.get_fairs_sql } }
  bm.report('Hybrid') { iterations.times { hybrid = estimator.get_fairs_hybrid } }
  bm.report('Fast') { iterations.times { fast = estimator.get_fairs_fast } }
end

def assert_hash_equal(name, left, right)
  left.transform_values!(&:to_f)
  right.transform_values!(&:to_f)
  left.each do |key, value|
    next if (value - right[key]) < 0.001
    puts "Error in #{name} at key #{key}: #{value} != #{right[key]}"
  end
end
bids, asks = Order.all.sort_by(&:price)
  .partition { |order| order.side == 'buy' }

book =  OrderBook.new(bids, asks)
puts "bids: #{book.instance_variable_get(:@bids).count}"
puts "Asks: #{book.instance_variable_get(:@asks).count}"
puts "Total: #{ClearedOrder.count}"

# assert_hash_equal ruby, sql
assert_hash_equal 'Ruby versus hybrid', ruby, hybrid
assert_hash_equal 'Ruby versus fast', ruby, fast

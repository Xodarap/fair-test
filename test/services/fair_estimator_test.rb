require 'test_helper'
require 'services/fair_estimator'

class FairEstimatorTest < ActiveSupport::TestCase
  fixtures :all

  test 'sql == Ruby' do
    estimator = FairEstimator.new
    assert_hash_equal estimator.get_fairs_ruby, estimator.get_fairs_sql
    assert_hash_equal estimator.get_fairs_ruby, estimator.get_fairs_hybrid
    assert_hash_equal estimator.get_fairs_ruby, estimator.get_fairs_fast
    assert_equal 105, estimator.get_fairs_ruby[['BTW', 'ABC']]
  end

  test 'sql == Ruby Cleared orders' do
    estimator = FairEstimator.new
    book = estimator.send(:create_book, Order.all)
    assert_equal ClearedOrder.where(side: 'buy').count, book.instance_variable_get(:@bids).count
    assert_equal ClearedOrder.where(side: 'sell').count, book.instance_variable_get(:@asks).count
  end

  private
  def assert_hash_equal(left, right)
    left.transform_values!(&:to_f)
    right.transform_values!(&:to_f)
    assert_equal left, right
  end
end
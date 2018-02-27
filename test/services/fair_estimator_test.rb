require 'test_helper'
require 'services/fair_estimator'

class FairEstimatorTest < ActiveSupport::TestCase
  fixtures :all

  test 'sql == Ruby' do
    estimator = FairEstimator.new
    assert_hash_equal estimator.get_fairs_ruby, estimator.get_fairs_sql
  end


  private
  def assert_hash_equal(left, right)
    left.transform_values!(&:to_f)
    right.transform_values!(&:to_f)
    assert_equal left, right
  end
end
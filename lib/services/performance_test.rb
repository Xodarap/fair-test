require 'benchmark'
require 'services/fair_estimator'

estimator = FairEstimator.new
iterations = 1

Benchmark.bm do |bm|
  bm.report('Ruby') { iterations.times { estimator.get_fairs_ruby } }
  bm.report('Sql') { iterations.times { estimator.get_fairs_sql } }
  bm.report('Hybrid') { iterations.times { estimator.get_fairs_hybrid } }
end
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
  bm.report('Sql') { iterations.times { sql = estimator.get_fairs_sql } }
  bm.report('Hybrid') { iterations.times { hybrid = estimator.get_fairs_hybrid } }
  bm.report('Fast') { iterations.times { fast = estimator.get_fairs_fast } }
end

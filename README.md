# fair-test

Calculates fair market values using a variety of methods.

This is really just a wrapper around two sql files: db/migrate/cleared_orders and db/migrate/fast_fair.

The fastest method runs in about 80 ms on my computer. Here are the results of the major methods I tried:

``````
# bundle exec rails runner lib/services/performance_test.rb
       user     system      total        real
Ruby  1.400000   0.050000   1.450000 (  1.493061)
Sql  0.000000   0.000000   0.000000 ( 10.502929)
Hybrid  1.350000   0.010000   1.360000 (  1.469051)
Fast  0.000000   0.000000   0.000000 (  0.091073)
``````

##Use


To use the "fast" method, just
```sql
select * from fast_fair
```

##Approaches
###Ruby

This method loads everything into Ruby and does all of the processing there. I am pretty sure that there is
a bug with this, as some of the values are different from the sql versions, in ways which cannot be correct.
I did not get a chance to finish investigating this though. In the unit tests it seems to work fine.

###Sql

This was an inefficient sql method which is kept around only for historical purposes. It differs from
"fast" in that it did a join to combine bids and asks instead of using case statements. It was not
easy to optimize the join because it was coming from a non-materialized view, so I cannot add indices.
Possibly we could consider materializing this view for even more performance improvements, depending
on how frequently we write to it, how fast that write has to be etc.

###Hybrid

This uses the sql view to clear all of the orders, but does the fair calculation itself.

Right now, the fair calculation is so simple that there does not seem to be any need to do anything in Ruby.
But if we add more things to the fair calculation it might be reasonable to split things up like this.

###Fast

This does everything in sql. It generally seems to be the best method, and runs in only 80 ms.

I don't really know how to do unit testing with complex sql stuff, so I made each CTE its own view.
This enables me to test it easily, but clutters up the database. Not sure what the best practices are here.
I also think we should use something to version the views if we continue, because the way rails handles
it is not very good.

Possibly we could consider materializing the cleared_orders view for even more performance improvements, depending
on how frequently we write to it, how fast that write has to be etc.
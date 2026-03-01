# dbops-project
Исходный репозиторий для выполнения проекта дисциплины "DBOps"

### Create `store` db

```sh
psql "host=<host> port=<port> dbname=store_default user=<user>"
store_default=# CREATE DATABASE store;
store_default=# \c store
store=# CREATE USER new_user WITH PASSWORD 'new_user_password';
store=# GRANT ALL PRIVILEGES ON DATABASE store TO new_user;
store=# GRANT USAGE ON SCHEMA public TO new_user;
store=# GRANT CREATE ON SCHEMA public TO new_user;
store=# ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO new_user;
```

### query before adding indexes
```sh
SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
    JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created;

 date_created |  sum
--------------+--------
 2026-02-23   | 946461
 2026-02-24   | 948984
 2026-02-25   | 942526
 2026-02-26   | 947998
 2026-02-27   | 946828
 2026-02-28   | 937490
 2026-03-01   | 506022
(7 rows)

Time: 22798.595 ms (00:22.799)

EXPLAIN ANALYZE:

Finalize GroupAggregate  (cost=266130.30..266153.36 rows=91 width=12) (actual time=2426.132..2434.904 rows=7 loops=1)
  Group Key: o.date_created
  ->  Gather Merge  (cost=266130.30..266151.54 rows=182 width=12) (actual time=2426.107..2434.877 rows=21 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=265130.28..265130.51 rows=91 width=12) (actual time=2396.477..2396.480 rows=7 loops=3)
              Sort Key: o.date_created
              Sort Method: quicksort  Memory: 25kB
              Worker 0:  Sort Method: quicksort  Memory: 25kB
              Worker 1:  Sort Method: quicksort  Memory: 25kB
              ->  Partial HashAggregate  (cost=265126.41..265127.32 rows=91 width=12) (actual time=2396.444..2396.448 rows=7 loops=3)
                    Group Key: o.date_created
                    Batches: 1  Memory Usage: 24kB
                    Worker 0:  Batches: 1  Memory Usage: 24kB
                    Worker 1:  Batches: 1  Memory Usage: 24kB
                    ->  Parallel Hash Join  (cost=148313.45..264611.93 rows=102895 width=8) (actual time=899.061..2377.806 rows=80768 loops=3)
                          Hash Cond: (op.order_id = o.id)
                          ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.13 rows=4166613 width=12) (actual time=0.037..398.783 rows=3333333 loops=3)
                          ->  Parallel Hash  (cost=147027.26..147027.26 rows=102895 width=12) (actual time=897.480..897.481 rows=80768 loops=3)
                                Buckets: 262144  Batches: 1  Memory Usage: 13472kB
                                ->  Parallel Seq Scan on orders o  (cost=0.00..147027.26 rows=102895 width=12) (actual time=13.697..846.447 rows=80768 loops=3)
                                      Filter: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                      Rows Removed by Filter: 3252565
Planning Time: 0.720 ms
JIT:
  Functions: 54
  Options: Inlining false, Optimization false, Expressions true, Deforming true
  Timing: Generation 4.117 ms, Inlining 0.000 ms, Optimization 3.221 ms, Emission 35.842 ms, Total 43.180 ms
Execution Time: 2454.108 ms
```

### query after adding indexes

```sh
SELECT o.date_created, SUM(op.quantity)
FROM orders AS o
    JOIN order_product AS op ON o.id = op.order_id
WHERE o.status = 'shipped' AND o.date_created > NOW() - INTERVAL '7 DAY'
GROUP BY o.date_created;

 date_created |  sum
--------------+--------
 2026-02-23   | 946461
 2026-02-24   | 948984
 2026-02-25   | 942526
 2026-02-26   | 947998
 2026-02-27   | 946828
 2026-02-28   | 937490
 2026-03-01   | 506022
(7 rows)

Time: 1259.004 ms (00:01.259)

EXPLAIN ANALYZE:

Finalize GroupAggregate  (cost=188240.36..188263.41 rows=91 width=12) (actual time=2283.129..2291.287 rows=7 loops=1)
  Group Key: o.date_created
  ->  Gather Merge  (cost=188240.36..188261.59 rows=182 width=12) (actual time=2283.099..2291.255 rows=21 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=187240.33..187240.56 rows=91 width=12) (actual time=2239.515..2239.519 rows=7 loops=3)
              Sort Key: o.date_created
              Sort Method: quicksort  Memory: 25kB
              Worker 0:  Sort Method: quicksort  Memory: 25kB
              Worker 1:  Sort Method: quicksort  Memory: 25kB
              ->  Partial HashAggregate  (cost=187236.46..187237.37 rows=91 width=12) (actual time=2239.483..2239.488 rows=7 loops=3)
                    Group Key: o.date_created
                    Batches: 1  Memory Usage: 24kB
                    Worker 0:  Batches: 1  Memory Usage: 24kB
                    Worker 1:  Batches: 1  Memory Usage: 24kB
                    ->  Parallel Hash Join  (cost=70422.81..186721.98 rows=102896 width=8) (actual time=326.047..2213.409 rows=80768 loops=3)
                          Hash Cond: (op.order_id = o.id)
                          ->  Parallel Seq Scan on order_product op  (cost=0.00..105361.67 rows=4166667 width=12) (actual time=0.031..568.405 rows=3333333 loops=3)
                          ->  Parallel Hash  (cost=69136.61..69136.61 rows=102896 width=12) (actual time=324.597..324.599 rows=80768 loops=3)
                                Buckets: 262144  Batches: 1  Memory Usage: 13472kB
                                ->  Parallel Bitmap Heap Scan on orders o  (cost=3383.69..69136.61 rows=102896 width=12) (actual time=33.667..276.679 rows=80768 loops=3)
                                      Recheck Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
                                      Heap Blocks: exact=27687
                                      ->  Bitmap Index Scan on orders_status_date_idx  (cost=0.00..3321.95 rows=246951 width=0) (actual time=45.712..45.712 rows=242304 loops=1)
                                            Index Cond: (((status)::text = 'shipped'::text) AND (date_created > (now() - '7 days'::interval)))
Planning Time: 0.427 ms
JIT:
  Functions: 57
  Options: Inlining false, Optimization false, Expressions true, Deforming true
  Timing: Generation 2.873 ms, Inlining 0.000 ms, Optimization 1.622 ms, Emission 47.897 ms, Total 52.393 ms
Execution Time: 2292.158 ms
```

### ВЫВОД

После добавления индексов время выполнения запроса сократилось в 18 раз, с 22798.595 ms до 1259.004 ms.
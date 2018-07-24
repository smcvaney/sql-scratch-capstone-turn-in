WITH months AS
(SELECT
	'2017-01-01' as first_day,
	'2017-01-31' as last_day
UNION
SELECT
	'2017-02-01' as first_day,
	'2017-02-28' as last_day
UNION
SELECT
	'2017-03-01' as first_day,
	'2017-03-31' as last_day
),
cross_join AS
(SELECT *
FROM subscriptions
CROSS JOIN months),
status AS
(SELECT segment, id, first_day as month,
CASE
		WHEN (subscription_start < first_day)     
 			AND (
      	subscription_end > first_day
      	OR subscription_end IS NULL
      )  	THEN 1
 		ELSE 0
END as is_active,
CASE
	WHEN (subscription_end BETWEEN first_day AND last_day)
 	THEN 1
 		ELSE 0
END as is_canceled
FROM cross_join),
status_aggregate AS
(SELECT
	segment,
	month,
	SUM(is_active) as sum_active,
	SUM(is_canceled) as sum_canceled
FROM status
GROUP BY month, segment)
SELECT 
	segment,
	month,
  1.0 * sum_canceled/sum_active AS churn_rate
FROM status_aggregate
ORDER BY segment;
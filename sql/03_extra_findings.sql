SELECT *
FROM `eidra-df-case.eidra_data_trainee.employees`
WHERE employee_id = 'EMP-004';

SELECT
  employee_id,
  DATE_TRUNC(date, MONTH) AS month,
  task_type,
  SUM(hours) AS hours
FROM `eidra-df-case.eidra_data_trainee.time_entries`
WHERE employee_id = 'EMP-004'
GROUP BY 1,2,3
ORDER BY 2,3;

-- this is the CTE for checking theoretical vs real revenue
WITH billable_time AS (
  SELECT
    t.employee_id,
    DATE_TRUNC(t.date, MONTH) AS month,
    p.client_id,
    p.opco,
    SUM(t.hours) AS billable_hours
  FROM `eidra-df-case.eidra_data_trainee.time_entries` t
  JOIN `eidra-df-case.eidra_data_trainee.projects` p
    ON t.project_id = p.project_id
  WHERE t.task_type = 'Billable'
    AND p.client_id IS NOT NULL
  GROUP BY 1,2,3,4
),

employee_rates AS (
  SELECT
    e.employee_id,
    e.seniority,
    COALESCE(e.works_for_opco, e.legal_opco) AS reporting_opco,
    r.standard_rate,
    r.currency
  FROM `eidra-df-case.eidra_data_trainee.employees` e
  JOIN `eidra-df-case.eidra_data_trainee.billing_rates` r
    ON COALESCE(e.works_for_opco, e.legal_opco) = r.opco
   AND e.seniority = r.seniority
),

theoretical_revenue AS (
  SELECT
    b.employee_id,
    b.month,
    b.client_id,
    b.opco,
    b.billable_hours,
    er.standard_rate,
    b.billable_hours * er.standard_rate AS theoretical_revenue
  FROM billable_time b
  JOIN employee_rates er
    ON b.employee_id = er.employee_id
),

client_month_totals AS (
  SELECT
    t.client_id,
    t.opco,
    t.month,
    SUM(t.theoretical_revenue) AS total_theoretical_revenue
  FROM theoretical_revenue t
  GROUP BY 1,2,3
),

revenue_share AS (
  SELECT
    t.employee_id,
    t.client_id,
    t.opco,
    t.month,
    t.theoretical_revenue,
    SAFE_DIVIDE(
      t.theoretical_revenue,
      c.total_theoretical_revenue
    ) AS revenue_share
  FROM theoretical_revenue t
  JOIN client_month_totals c
    ON t.client_id = c.client_id
   AND t.opco = c.opco
   AND t.month = c.month
),

final AS (
  SELECT
    rs.employee_id,
    rs.client_id,
    rs.opco,
    rs.month,
    rs.revenue_share,
    ir.revenue AS actual_revenue,
    rs.revenue_share * ir.revenue AS attributed_revenue
  FROM revenue_share rs
  JOIN `eidra-df-case.eidra_data_trainee.invoiced_revenue` ir
    ON rs.client_id = ir.client_id
   AND rs.opco = ir.opco
   AND rs.month = ir.month
),

theoretical AS (
  SELECT
    t.client_id,
    t.opco,
    t.month,
    SUM(t.theoretical_revenue) AS total_theoretical_revenue
  FROM theoretical_revenue t
  GROUP BY 1,2,3
),

actual AS (
  SELECT
    client_id,
    opco,
    month,
    MAX(actual_revenue) AS total_actual_revenue
  FROM final
  GROUP BY 1,2,3
)

SELECT
  t.client_id,
  t.opco,
  t.month,
  t.total_theoretical_revenue,
  a.total_actual_revenue,
  a.total_actual_revenue - t.total_theoretical_revenue AS revenue_gap,
  SAFE_DIVIDE(a.total_actual_revenue, t.total_theoretical_revenue) AS revenue_ratio
FROM theoretical t
JOIN actual a
  ON t.client_id = a.client_id
 AND t.opco = a.opco
 AND t.month = a.month
ORDER BY t.month, t.opco, t.client_id;
WITH employee_base AS (
  SELECT
    employee_id,
    name,
    COALESCE(works_for_opco, legal_opco) AS reporting_opco,
    country,
    employment_type,
    date_of_hiring,
    last_working_day
  FROM `eidra-df-case.eidra_data_trainee.employees`
),

employee_calendar AS (
  SELECT
    e.employee_id,
    e.name,
    e.reporting_opco,
    e.country,
    e.employment_type,
    c.date,
    DATE_TRUNC(c.date, MONTH) AS month,
    c.working_hours
  FROM employee_base e
  JOIN `eidra-df-case.eidra_data_trainee.calendar` c
    ON e.country = c.country
  WHERE c.is_working_day = TRUE
    AND c.date >= GREATEST(e.date_of_hiring, DATE_TRUNC(c.date, MONTH))
    AND c.date <= LEAST(COALESCE(e.last_working_day, DATE '2024-12-31'), LAST_DAY(c.date))
),

monthly_available_hours AS (
  SELECT
    employee_id,
    name,
    reporting_opco,
    country,
    employment_type,
    month,
    SUM(working_hours) AS available_hours
  FROM employee_calendar
  GROUP BY 1,2,3,4,5,6
),

monthly_billable_hours AS (
  SELECT
    employee_id,
    DATE_TRUNC(date, MONTH) AS month,
    SUM(hours) AS billable_hours
  FROM `eidra-df-case.eidra_data_trainee.time_entries`
  WHERE task_type = 'Billable'
  GROUP BY 1,2
),

monthly_absence_hours AS (
  SELECT
    employee_id,
    DATE_TRUNC(date, MONTH) AS month,
    SUM(hours) AS absence_hours
  FROM `eidra-df-case.eidra_data_trainee.time_entries`
  WHERE task_type IN ('Absence Planned', 'Absence Unplanned')
  GROUP BY 1,2
),

final AS (
  SELECT
    a.employee_id,
    a.name,
    a.reporting_opco AS opco,
    a.country,
    a.employment_type,
    a.month,
    a.available_hours,
    COALESCE(abs.absence_hours, 0) AS absence_hours,
    COALESCE(b.billable_hours, 0) AS billable_hours,

    -- Adjusted denominator
    (a.available_hours - COALESCE(abs.absence_hours, 0)) AS net_available_hours,

    SAFE_DIVIDE(
      COALESCE(b.billable_hours, 0),
      (a.available_hours - COALESCE(abs.absence_hours, 0))
    ) AS chargeability_pct

  FROM monthly_available_hours a
  LEFT JOIN monthly_billable_hours b
    ON a.employee_id = b.employee_id
   AND a.month = b.month
  LEFT JOIN monthly_absence_hours abs
    ON a.employee_id = abs.employee_id
   AND a.month = abs.month
)

SELECT *
FROM final
ORDER BY month, opco, name;
# Recommended first-pass assumptions

- Billable hours are the numerator.
- Denominator is based on standard working calendar hours, not total logged hours.
- Employees only count from date_of_hiring to last_working_day.
- If last_working_day is null, treat them as active through the dataset end.
- Country-specific working calendars matter.
- **works_for_opco** should probably override **legal_opco** for operational reporting.
- Part-time employees are tricky because there is no explicit workload percentage column. I’d flag this as a limitation.
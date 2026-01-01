DELETE FROM fct_ProductionPlan
DBCC CHECKIDENT('fct_ProductionPlan', RESEED, 0);

WITH ProductionRules AS (
	SELECT
		1 AS LineID,
		1 AS ProductID,
		200 AS TargetQuantity
	UNION ALL
	SELECT
		2 AS LineID,
		3 AS ProductID,
		500 AS TargetQuantity
	UNION ALL
	SELECT
		3 AS LineID,
		3 AS ProductID,
		80 AS TargetQuantity
)

INSERT INTO fct_ProductionPlan (StartShiftDate, ShiftID, LineID, ProductID, TargetQuantity)
SELECT
	s.StartShiftDate,
	s.ShiftID,
	r.LineID,
	r.ProductID,
	r.TargetQuantity
FROM dim_Shifts AS s
CROSS JOIN ProductionRules AS r
WHERE s.StartShiftDate >= '2026-01-01'
AND s.StartShiftDate < '2026-05-01'
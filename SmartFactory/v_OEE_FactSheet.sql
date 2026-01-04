/*
	Connect three views:
		v_Daily_Availability
		v_Daily_Performance
		v_Daily_Quality
	And calculate Daily OEE KPI Value
*/
CREATE OR ALTER VIEW v_OEE_FactSheet
AS
	SELECT
		p.DateDay,
		a.LineID,
		a.MachineID,
		a.AvailabilityKPI_Value,
		q.QualityKPI_Value,
		p.DailyPerformanceKPI_Value,
		a.AvailabilityKPI_Value * q.QualityKPI_Value * p.DailyPerformanceKPI_Value AS DailyOeeKPI_Value
	FROM
		v_Daily_Availability AS a
		INNER JOIN v_DailyQualityPerMachine AS q
			ON 
				a.Data = q.DateValue
				AND a.LineID = q.LineID
				AND a.MachineID = q.MachineID
		INNER JOIN v_Daily_Performance AS p
			ON
				a.Data = p.DateDay
				AND a.LineID = p.LineID
				AND a.MachineID = p.MachineID
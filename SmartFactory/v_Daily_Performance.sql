/*
	DAILY PERFORMANCE FOR EACH MACHINE

	I count performance by this equation Performance = AmountOfDetails * (IdealCycleTime / RunTime)
	I use SUM to calculate AmountOfDetails = Sum(IsGood) + Sum(IsScrap)
	I took AVG of RunTime from another View v_Daily_Availability
	Then took this valuesa and put into equation.
*/

CREATE OR ALTER VIEW v_Daily_Performance
AS
	SELECT 
		CAST(po.Timestamp AS DATE) AS DateDay,
		l.LineID,
		po.MachineID,
		MAX(p.IdealCycleTime_sec) AS CycleTime,
		SUM(po.IsGood) + SUM(po.IsScrap) AS AmountOfDetails,
		AVG(av.RunTime) AS RunTime,
		(SUM((po.IsGood + po.IsScrap) * p.IdealCycleTime_sec)) / NULLIF(AVG(av.RunTime), 0) AS DailyPerformanceKPI_Value
	FROM fct_ProductionOutput AS po
		LEFT JOIN dim_Products AS p
			ON po.ProductID = p.ProductID
		LEFT JOIN dim_Machines AS m
			ON po.MachineID = m.MachineID
		LEFT JOIN dim_Lines AS l
			ON m.LineID = l.LineID
		LEFT JOIN v_Daily_Availability AS av
			ON po.MachineID = av.MachineID AND CAST(po.Timestamp AS DATE) = av.Data
	WHERE p.IsCurrent = 1
	GROUP BY CAST(po.Timestamp AS DATE), l.LineID, po.MachineID
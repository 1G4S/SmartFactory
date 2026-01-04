/*
	DAILY AVAILABILITY DATA FOR EACH MACHINE
	
	Because this problem is more complex i decided to create two CTE's.
	First one (malfunction_time), is adding, malfunctions times. 
	I calculate them by substraction of two columns StartTime and EndTime.

	Second one (planned_working_time) was created to count how many seconds there are in each day.
	And to join data properly if there is no malfunctions for machine in some day.
*/
CREATE OR ALTER VIEW v_Daily_Availability
AS
	WITH malfunction_time 
	AS (
		SELECT 
			CAST(StartTime AS DATE) AS DateDay,
			me.MachineID AS MachineID,
			SUM(DATEDIFF(ss, me.StartTime, me.EndTime)) AS MalfunctionTime
		FROM 
			fct_MachineEvents me
		GROUP BY CAST(StartTime AS DATE), me.MachineID
	), 

	planned_working_time 
	AS
	(
		SELECT 
			CAST(s.StartShiftDate AS Date) AS Data, 
			SUM(DATEDIFF(ss, s.StartShiftDate, s.EndShiftDate)) AS PlanTime
		FROM dim_Shifts AS s
		GROUP BY CAST(s.StartShiftDate AS DATE)
	)

	SELECT
		p.Data,
		l.LineID,
		m.MachineID,
		ISNULL(ma.MalfunctionTime, 0) AS MalfunctionTime,
		p.PlanTime,
		p.PlanTime - ma.MalfunctionTime AS RunTime,
		(p.Plantime - CAST(ISNULL(ma.MalfunctionTime, 0) AS FLOAT)) / NULLIF(p.PlanTime, 0) AS AvailabilityKPI_Value
	FROM dim_Machines AS m
		INNER JOIN dim_Lines AS l
		ON m.LineID = l.LineID
		CROSS JOIN planned_working_time AS p
		LEFT JOIN malfunction_time AS ma
		ON m.MachineID = ma.MachineID AND p.Data = ma.DateDay
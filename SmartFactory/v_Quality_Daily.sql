/*
	DAILY QUALITY DATA FOR EACH MACHINE 

	Because IsGood and IsScrap are representing by 0, 1, we use these column to sum each.
	Then we count percent of quality on each machine from each line.
	We have to join three tables, 
	first to get product name from dim_Products,
	second to get machine name from dim_Machines,
	third to get line name from dim_Lines.
	Finally we group by DateKey(daily), LineID, MachineID and ProductID.  
*/

CREATE OR ALTER VIEW v_DailyQualityPerMachine
AS	
SELECT
	po.DateKey,
	l.LineID,
	l.LineName,
	po.MachineID,
	m.MachineName,
	po.ProductID,
	p.ProductName,
	SUM(po.IsGood) AS amount_of_good_details,
	SUM(po.IsScrap) AS amount_of_scrap_details,
	ISNULL(CAST(SUM(po.IsGood) AS FLOAT) / NULLIF(COUNT(*), 0), 0) AS QualityKPI_Value
FROM 
	fct_ProductionOutput AS po
		INNER JOIN dim_Products AS p
		ON po.ProductID = p.ProductID
		INNER JOIN dim_Machines AS m
		ON po.MachineID = m.MachineID
		INNER JOIN dim_Lines AS l
		ON m.LineID = l.LineID
GROUP BY po.DateKey, l.LineID, l.LineName, po.MachineID, m.MachineName, po.ProductID, p.ProductName

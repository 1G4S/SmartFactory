/*
	DAILY QUALITY DATA FOR EACH MACHINE 

	Because IsGood and IsScrap are representing by 0, 1, I use these column to sum each.
	Then count percent of quality on each machine from each line.
	I have to join three tables, 
	first to get product name from dim_Products,
	second to get machine name from dim_Machines,
	third to get line name from dim_Lines.
	Finally group by DateKey(daily), LineID, MachineID and ProductID.  
*/

CREATE OR ALTER VIEW v_DailyQualityPerMachine
AS	
SELECT
		po.DateKey,
		CAST(po.Timestamp AS DATE) AS DateValue,
		l.LineID,
		po.MachineID,
		po.ProductID,
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
GROUP BY po.DateKey, CAST(po.Timestamp AS DATE), l.LineID, po.MachineID, po.ProductID

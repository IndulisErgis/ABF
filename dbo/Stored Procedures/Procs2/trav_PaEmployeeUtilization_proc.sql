
CREATE PROCEDURE dbo.trav_PaEmployeeUtilization_proc
@PrintDetail tinyint = 0, 
@StartYear smallint,
@StartMonth tinyint,
@FTThreshold smallint = 130,
@FTEDivisor smallint = 120
AS
SET NOCOUNT ON
BEGIN TRY
	
	DECLARE @YearMonthFrom int, @YearMonthThru int

	CREATE TABLE #tmpDetail 
	(
		GroupType tinyint NOT NULL, 
		EmployeeId pEmpID NOT NULL,
		Month1 pDecimal NOT NULL,
		Month2 pDecimal NOT NULL,
		Month3 pDecimal NOT NULL,
		Month4 pDecimal NOT NULL,
		Month5 pDecimal NOT NULL,
		Month6 pDecimal NOT NULL,
		Month7 pDecimal NOT NULL,
		Month8 pDecimal NOT NULL,
		Month9 pDecimal NOT NULL,
		Month10 pDecimal NOT NULL,
		Month11 pDecimal NOT NULL,
		Month12 pDecimal NOT NULL
		PRIMARY KEY CLUSTERED (GroupType, EmployeeId)
	)

	CREATE TABLE #tmpSalaryEmployee
	(
		EmployeeId pEmpID NOT NULL,
		PaMonth tinyint NOT NULL
		PRIMARY KEY CLUSTERED (EmployeeId, PaMonth)
	)

	SELECT @YearMonthFrom = @StartYear * 1000 + @StartMonth, 
		@YearMonthThru = CASE @StartMonth WHEN 1 THEN @StartYear ELSE @StartYear + 1 END * 1000 + CASE @StartMonth WHEN 1 THEN 12 ELSE @StartMonth - 1 END

	INSERT INTO #tmpSalaryEmployee (EmployeeId, PaMonth)
	SELECT EmployeeId, PaMonth
	FROM dbo.tblPaCheckHist 
	WHERE PaYear * 1000 + PaMonth BETWEEN @YearMonthFrom AND @YearMonthThru
		AND Voided = 0 AND EmployeeType = 1 AND EmployeeId IN (SELECT EmployeeId FROM #tmpEmployee)
	GROUP BY EmployeeId, PaMonth
	HAVING Count(*) > 0

	INSERT INTO #tmpDetail (GroupType, EmployeeId, Month1, Month2, Month3, Month4, Month5, Month6, Month7, Month8, Month9, Month10, Month11, Month12)
	--Salaried Employee, has at least one salary check run in a payroll month
	SELECT 0 AS GroupType, s.EmployeeId,
		SUM(CASE WHEN PaMonth = @StartMonth THEN HasCheck ELSE 0 END) AS Month1, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 1) WHEN 12 THEN 12 ELSE (@StartMonth + 1) % 12 END THEN HasCheck ELSE 0 END) AS Month2,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 2) WHEN 12 THEN 12 ELSE (@StartMonth + 2) % 12 END THEN HasCheck ELSE 0 END) AS Month3,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 3) WHEN 12 THEN 12 ELSE (@StartMonth + 3) % 12 END THEN HasCheck ELSE 0 END) AS Month4,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 4) WHEN 12 THEN 12 ELSE (@StartMonth + 4) % 12 END THEN HasCheck ELSE 0 END) AS Month5, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 5) WHEN 12 THEN 12 ELSE (@StartMonth + 5) % 12 END THEN HasCheck ELSE 0 END) AS Month6,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 6) WHEN 12 THEN 12 ELSE (@StartMonth + 6) % 12 END THEN HasCheck ELSE 0 END) AS Month7, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 7) WHEN 12 THEN 12 ELSE (@StartMonth + 7) % 12 END THEN HasCheck ELSE 0 END) AS Month8,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 8) WHEN 12 THEN 12 ELSE (@StartMonth + 8) % 12 END THEN HasCheck ELSE 0 END) AS Month9, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 9) WHEN 12 THEN 12 ELSE (@StartMonth + 9) % 12 END THEN HasCheck ELSE 0 END) AS Month10,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 10) WHEN 12 THEN 12 ELSE (@StartMonth + 10) % 12 END THEN HasCheck ELSE 0 END) AS Month11, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 11) WHEN 12 THEN 12 ELSE (@StartMonth + 11) % 12 END THEN HasCheck ELSE 0 END) AS Month12
	FROM (
	SELECT EmployeeId, PaMonth, CASE WHEN Count(*) > 0 THEN 1 ELSE 0 END AS HasCheck
	FROM dbo.tblPaCheckHist 
	WHERE PaYear * 1000 + PaMonth BETWEEN @YearMonthFrom AND @YearMonthThru
		AND Voided = 0 AND EmployeeType = 1 AND EmployeeId IN (SELECT EmployeeId FROM #tmpEmployee)
	GROUP BY EmployeeId, PaMonth) s 
	GROUP BY s.EmployeeId
	UNION ALL
	--Full-Time Hourly Employee, Hours at or Exceeding FT Threshold (default to 130 hours/month)
	SELECT 1 AS GroupType, f.EmployeeId,
		SUM(CASE WHEN PaMonth = @StartMonth THEN 1 ELSE 0 END) AS Month1, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 1) WHEN 12 THEN 12 ELSE (@StartMonth + 1) % 12 END THEN 1 ELSE 0 END) AS Month2,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 2) WHEN 12 THEN 12 ELSE (@StartMonth + 2) % 12 END THEN 1 ELSE 0 END) AS Month3,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 3) WHEN 12 THEN 12 ELSE (@StartMonth + 3) % 12 END THEN 1 ELSE 0 END) AS Month4,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 4) WHEN 12 THEN 12 ELSE (@StartMonth + 4) % 12 END THEN 1 ELSE 0 END) AS Month5,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 5) WHEN 12 THEN 12 ELSE (@StartMonth + 5) % 12 END THEN 1 ELSE 0 END) AS Month6,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 6) WHEN 12 THEN 12 ELSE (@StartMonth + 6) % 12 END THEN 1 ELSE 0 END) AS Month7,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 7) WHEN 12 THEN 12 ELSE (@StartMonth + 7) % 12 END THEN 1 ELSE 0 END) AS Month8,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 8) WHEN 12 THEN 12 ELSE (@StartMonth + 8) % 12 END THEN 1 ELSE 0 END) AS Month9,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 9) WHEN 12 THEN 12 ELSE (@StartMonth + 9) % 12 END THEN 1 ELSE 0 END) AS Month10,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 10) WHEN 12 THEN 12 ELSE (@StartMonth + 10) % 12 END THEN 1 ELSE 0 END) AS Month11,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 11) WHEN 12 THEN 12 ELSE (@StartMonth + 11) % 12 END THEN 1 ELSE 0 END) AS Month12
	FROM (
	SELECT c.EmployeeId, MONTH(c.TransDate) AS PaMonth, SUM(c.[Hours]) AS TotalHour
	FROM dbo.tblPaTransEarnHist c LEFT JOIN #tmpSalaryEmployee t ON c.EmployeeId = t.EmployeeId AND MONTH(c.TransDate) = t.PaMonth
	WHERE YEAR(c.TransDate) * 1000 + MONTH(c.TransDate) BETWEEN @YearMonthFrom AND @YearMonthThru 
		AND c.Voided = 0 AND c.EmployeeId IN (SELECT EmployeeId FROM #tmpEmployee) AND t.EmployeeId IS NULL
	GROUP BY c.EmployeeId, MONTH(c.TransDate) ) f 
	WHERE TotalHour >= @FTThreshold 
	GROUP BY f.EmployeeId
	UNION ALL
	--Part-Time Hourly Employee, Hours less than FT Threshold (default to 130 hours/month) and Maximum to FTE Divisor (default to 120 hours)
	SELECT 2 AS GroupType, f.EmployeeId,
		SUM(CASE WHEN PaMonth = @StartMonth THEN CalculateHour ELSE 0 END) AS Month1, 
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 1) WHEN 12 THEN 12 ELSE (@StartMonth + 1) % 12 END THEN CalculateHour ELSE 0 END) AS Month2,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 2) WHEN 12 THEN 12 ELSE (@StartMonth + 2) % 12 END THEN CalculateHour ELSE 0 END) AS Month3,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 3) WHEN 12 THEN 12 ELSE (@StartMonth + 3) % 12 END THEN CalculateHour ELSE 0 END) AS Month4,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 4) WHEN 12 THEN 12 ELSE (@StartMonth + 4) % 12 END THEN CalculateHour ELSE 0 END) AS Month5,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 5) WHEN 12 THEN 12 ELSE (@StartMonth + 5) % 12 END THEN CalculateHour ELSE 0 END) AS Month6,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 6) WHEN 12 THEN 12 ELSE (@StartMonth + 6) % 12 END THEN CalculateHour ELSE 0 END) AS Month7,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 7) WHEN 12 THEN 12 ELSE (@StartMonth + 7) % 12 END THEN CalculateHour ELSE 0 END) AS Month8,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 8) WHEN 12 THEN 12 ELSE (@StartMonth + 8) % 12 END THEN CalculateHour ELSE 0 END) AS Month9,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 9) WHEN 12 THEN 12 ELSE (@StartMonth + 9) % 12 END THEN CalculateHour ELSE 0 END) AS Month10,
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 10) WHEN 12 THEN 12 ELSE (@StartMonth + 10) % 12 END THEN CalculateHour ELSE 0 END) AS Month11,  
		SUM(CASE WHEN PaMonth = CASE (@StartMonth + 11) WHEN 12 THEN 12 ELSE (@StartMonth + 11) % 12 END THEN CalculateHour ELSE 0 END) AS Month12
	FROM (
	SELECT c.EmployeeId, MONTH(c.TransDate) AS PaMonth, SUM(c.[Hours]) AS TotalHour, CASE WHEN SUM(c.[Hours]) >= @FTEDivisor THEN @FTEDivisor ELSE SUM(c.[Hours]) END CalculateHour
	FROM dbo.tblPaTransEarnHist c LEFT JOIN #tmpSalaryEmployee t ON c.EmployeeId = t.EmployeeId AND MONTH(c.TransDate) = t.PaMonth
	WHERE YEAR(c.TransDate) * 1000 + MONTH(c.TransDate) BETWEEN @YearMonthFrom AND @YearMonthThru 
		AND c.Voided = 0 AND c.EmployeeId IN (SELECT EmployeeId FROM #tmpEmployee) AND t.EmployeeId IS NULL
	GROUP BY c.EmployeeId, MONTH(c.TransDate) ) f 
	WHERE TotalHour < @FTThreshold 
	GROUP BY f.EmployeeId

	SELECT 0 AS RecordType, t.GroupType, t.EmployeeId, e.[Status], p.EmployeeType, CASE WHEN e.FirstName IS NULL THEN e.LastName ELSE e.FirstName + ' ' + ISNULL(e.LastName, '') END AS EmployeeName,
		t.Month1, t.Month2, t.Month3, t.Month4, t.Month5, t.Month6, t.Month7, t.Month8, t.Month9, t.Month10, t.Month11, t.Month12
	FROM #tmpDetail t INNER JOIN dbo.tblPaEmployee p ON t.EmployeeId = p.EmployeeId 
		INNER JOIN dbo.tblSmEmployee e ON p.EmployeeId = e.EmployeeId 
	WHERE @PrintDetail = 0
	UNION ALL
	--Full-Time Equivalent (FTE) Employee, Part-Time Hours Divided by FTE Divisor (default to 120 hours)
	SELECT 0 AS RecordType, 3 AS GroupType, NULL AS EmployeeId, NULL AS [Status], NULL AS EmployeeType, NULL AS EmployeeName,
		ISNULL(CAST(CASE WHEN SUM(Month1) >= @FTEDivisor THEN FLOOR(SUM(Month1) / @FTEDivisor) ELSE CEILING(SUM(Month1) / @FTEDivisor) END AS decimal(28,10)),0) AS Month1, 
		ISNULL(CAST(CASE WHEN SUM(Month2) >= @FTEDivisor THEN FLOOR(SUM(Month2) / @FTEDivisor) ELSE CEILING(SUM(Month2) / @FTEDivisor) END AS decimal(28,10)),0) AS Month2,
		ISNULL(CAST(CASE WHEN SUM(Month3) >= @FTEDivisor THEN FLOOR(SUM(Month3) / @FTEDivisor) ELSE CEILING(SUM(Month3) / @FTEDivisor) END AS decimal(28,10)),0) AS Month3,  
		ISNULL(CAST(CASE WHEN SUM(Month4) >= @FTEDivisor THEN FLOOR(SUM(Month4) / @FTEDivisor) ELSE CEILING(SUM(Month4) / @FTEDivisor) END AS decimal(28,10)),0) AS Month4,
		ISNULL(CAST(CASE WHEN SUM(Month5) >= @FTEDivisor THEN FLOOR(SUM(Month5) / @FTEDivisor) ELSE CEILING(SUM(Month5) / @FTEDivisor) END AS decimal(28,10)),0) AS Month5,  
		ISNULL(CAST(CASE WHEN SUM(Month6) >= @FTEDivisor THEN FLOOR(SUM(Month6) / @FTEDivisor) ELSE CEILING(SUM(Month6) / @FTEDivisor) END AS decimal(28,10)),0) AS Month6,
		ISNULL(CAST(CASE WHEN SUM(Month7) >= @FTEDivisor THEN FLOOR(SUM(Month7) / @FTEDivisor) ELSE CEILING(SUM(Month7) / @FTEDivisor) END AS decimal(28,10)),0) AS Month7,  
		ISNULL(CAST(CASE WHEN SUM(Month8) >= @FTEDivisor THEN FLOOR(SUM(Month8) / @FTEDivisor) ELSE CEILING(SUM(Month8) / @FTEDivisor) END AS decimal(28,10)),0) AS Month8,
		ISNULL(CAST(CASE WHEN SUM(Month9) >= @FTEDivisor THEN FLOOR(SUM(Month9) / @FTEDivisor) ELSE CEILING(SUM(Month9) / @FTEDivisor) END AS decimal(28,10)),0) AS Month9,  
		ISNULL(CAST(CASE WHEN SUM(Month10) >= @FTEDivisor THEN FLOOR(SUM(Month10) / @FTEDivisor) ELSE CEILING(SUM(Month10) / @FTEDivisor) END AS decimal(28,10)),0) AS Month10,
		ISNULL(CAST(CASE WHEN SUM(Month11) >= @FTEDivisor THEN FLOOR(SUM(Month11) / @FTEDivisor) ELSE CEILING(SUM(Month11) / @FTEDivisor) END AS decimal(28,10)),0) AS Month11,  
		ISNULL(CAST(CASE WHEN SUM(Month12) >= @FTEDivisor THEN FLOOR(SUM(Month12) / @FTEDivisor) ELSE CEILING(SUM(Month12) / @FTEDivisor) END AS decimal(28,10)),0) AS Month12
	FROM #tmpDetail
	WHERE @PrintDetail = 0 AND GroupType = 2 
	GROUP BY GroupType
	UNION ALL
	SELECT 1 AS RecordType, 4 AS GroupType, NULL AS EmployeeId, NULL AS [Status], NULL AS EmployeeType, NULL AS EmployeeName,
		ISNULL(SUM(Month1),0) AS Month1, ISNULL(SUM(Month2),0) AS Month2, ISNULL(SUM(Month3),0) AS Month3, ISNULL(SUM(Month4),0) AS Month4, 
		ISNULL(SUM(Month5),0) AS Month5, ISNULL(SUM(Month6),0) AS Month6, ISNULL(SUM(Month7),0) AS Month7, ISNULL(SUM(Month8),0) AS Month8, ISNULL(SUM(Month9),0) AS Month9, 
		ISNULL(SUM(Month10),0) AS Month10, ISNULL(SUM(Month11),0) AS Month11, ISNULL(SUM(Month12),0) AS Month12
	FROM #tmpDetail 
	WHERE GroupType = 0
	UNION ALL
	SELECT 1 AS RecordType, 5 AS GroupType, NULL AS EmployeeId, NULL AS [Status], NULL AS EmployeeType, NULL AS EmployeeName,
		ISNULL(SUM(Month1),0) AS Month1, ISNULL(SUM(Month2),0) AS Month2, ISNULL(SUM(Month3),0) AS Month3, ISNULL(SUM(Month4),0) AS Month4, 
		ISNULL(SUM(Month5),0) AS Month5, ISNULL(SUM(Month6),0) AS Month6, ISNULL(SUM(Month7),0) AS Month7, ISNULL(SUM(Month8),0) AS Month8, ISNULL(SUM(Month9),0) AS Month9, 
		ISNULL(SUM(Month10),0) AS Month10, ISNULL(SUM(Month11),0) AS Month11, ISNULL(SUM(Month12),0) AS Month12
	FROM #tmpDetail 
	WHERE GroupType = 1
	UNION ALL
	SELECT 1 AS RecordType, 6 AS GroupType, NULL AS EmployeeId, NULL AS [Status], NULL AS EmployeeType, NULL AS EmployeeName,
		ISNULL(SUM(Month1),0) AS Month1, ISNULL(SUM(Month2),0) AS Month2, ISNULL(SUM(Month3),0) AS Month3, ISNULL(SUM(Month4),0) AS Month4, 
		ISNULL(SUM(Month5),0) AS Month5, ISNULL(SUM(Month6),0) AS Month6, ISNULL(SUM(Month7),0) AS Month7, ISNULL(SUM(Month8),0) AS Month8, ISNULL(SUM(Month9),0) AS Month9, 
		ISNULL(SUM(Month10),0) AS Month10, ISNULL(SUM(Month11),0) AS Month11, ISNULL(SUM(Month12),0) AS Month12
	FROM #tmpDetail 
	WHERE GroupType = 2
	UNION ALL
	SELECT 1 AS RecordType, 7 AS GroupType, NULL AS EmployeeId, NULL AS [Status], NULL AS EmployeeType, NULL AS EmployeeName,
		ISNULL(CAST(CASE WHEN SUM(Month1) >= @FTEDivisor THEN FLOOR(SUM(Month1) / @FTEDivisor) ELSE CEILING(SUM(Month1) / @FTEDivisor) END AS decimal(28,10)),0) AS Month1, 
		ISNULL(CAST(CASE WHEN SUM(Month2) >= @FTEDivisor THEN FLOOR(SUM(Month2) / @FTEDivisor) ELSE CEILING(SUM(Month2) / @FTEDivisor) END AS decimal(28,10)),0) AS Month2,
		ISNULL(CAST(CASE WHEN SUM(Month3) >= @FTEDivisor THEN FLOOR(SUM(Month3) / @FTEDivisor) ELSE CEILING(SUM(Month3) / @FTEDivisor) END AS decimal(28,10)),0) AS Month3,  
		ISNULL(CAST(CASE WHEN SUM(Month4) >= @FTEDivisor THEN FLOOR(SUM(Month4) / @FTEDivisor) ELSE CEILING(SUM(Month4) / @FTEDivisor) END AS decimal(28,10)),0) AS Month4,
		ISNULL(CAST(CASE WHEN SUM(Month5) >= @FTEDivisor THEN FLOOR(SUM(Month5) / @FTEDivisor) ELSE CEILING(SUM(Month5) / @FTEDivisor) END AS decimal(28,10)),0) AS Month5,  
		ISNULL(CAST(CASE WHEN SUM(Month6) >= @FTEDivisor THEN FLOOR(SUM(Month6) / @FTEDivisor) ELSE CEILING(SUM(Month6) / @FTEDivisor) END AS decimal(28,10)),0) AS Month6,
		ISNULL(CAST(CASE WHEN SUM(Month7) >= @FTEDivisor THEN FLOOR(SUM(Month7) / @FTEDivisor) ELSE CEILING(SUM(Month7) / @FTEDivisor) END AS decimal(28,10)),0) AS Month7,  
		ISNULL(CAST(CASE WHEN SUM(Month8) >= @FTEDivisor THEN FLOOR(SUM(Month8) / @FTEDivisor) ELSE CEILING(SUM(Month8) / @FTEDivisor) END AS decimal(28,10)),0) AS Month8,
		ISNULL(CAST(CASE WHEN SUM(Month9) >= @FTEDivisor THEN FLOOR(SUM(Month9) / @FTEDivisor) ELSE CEILING(SUM(Month9) / @FTEDivisor) END AS decimal(28,10)),0) AS Month9,  
		ISNULL(CAST(CASE WHEN SUM(Month10) >= @FTEDivisor THEN FLOOR(SUM(Month10) / @FTEDivisor) ELSE CEILING(SUM(Month10) / @FTEDivisor) END AS decimal(28,10)),0) AS Month10,
		ISNULL(CAST(CASE WHEN SUM(Month11) >= @FTEDivisor THEN FLOOR(SUM(Month11) / @FTEDivisor) ELSE CEILING(SUM(Month11) / @FTEDivisor) END AS decimal(28,10)),0) AS Month11,  
		ISNULL(CAST(CASE WHEN SUM(Month12) >= @FTEDivisor THEN FLOOR(SUM(Month12) / @FTEDivisor) ELSE CEILING(SUM(Month12) / @FTEDivisor) END AS decimal(28,10)),0) AS Month12
	FROM #tmpDetail
	WHERE GroupType = 2
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployeeUtilization_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaEmployeeUtilization_proc';


CREATE PROCEDURE [dbo].[trav_HrLongevity_proc]
@SortBy tinyint,
@SpecStat bit,
@AsOfDate datetime,
@DepartmentFrom pDeptID,
@DepartmentThru pDeptID

AS
SET NOCOUNT ON
BEGIN TRY
	--assign a default as of date when needed
	SELECT @AsOfDate = ISNULL(@AsOfDate, GETDATE())

	--start will all individuals
	CREATE TABLE #IndividualList ([IndID] [pEmpId], Primary Key ([IndID]))
	INSERT INTO #IndividualList SELECT [IndId] FROM dbo.tblHrIndGenInfo

	--identify the current position as of the given date
	CREATE TABLE #IndPositionID (IndId [pEmpID], IndPositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @AsOfDate

	--identify the current status of the list of individuals
	CREATE TABLE #IndStatus (IndId [pEmpID] NOT NULL, IndStatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @AsOfDate, 1 -- 1:Active individuals

	--isolate the individuals to include
	--	based on the department or special status
	CREATE TABLE #RptIndInfo ([IndID] [pEmpId], [Department] pDeptID NULL, [JobTypeCodeID] bigint, Primary Key ([IndID]))
	INSERT INTO #RptIndInfo ([IndID], [Department], [JobTypeCodeID])
	SELECT i.[IndId], p.[Department], p.[JobTypeCodeID]
			FROM #IndStatus s
			INNER JOIN #IndPositionID i on s.[IndId] = i.[IndId]
			INNER JOIN dbo.tblHrIndPosition ip on i.IndId = ip.IndId and i.IndPositionID = ip.ID
			INNER JOIN dbo.tblHrPosition p on ip.PositionID = p.ID
			INNER JOIN dbo.tblHrJobTitle jt on p.JobTypeCodeID = jt.ID
			INNER JOIN #LongevityList ll on ll.ID = jt.ID --apply the selected job filter
			WHERE (@SpecStat = 1 OR p.SpecialStatus = 0)
				AND (@DepartmentFrom IS NULL OR @DepartmentThru IS NULL OR (p.Department BETWEEN @DepartmentFrom AND @DepartmentThru))

	--retrieve the department groupings
	SELECT ri.[Department], pd.[DepartmentName]
	FROM #RptIndInfo ri
	LEFT JOIN dbo.tblPaDept pd ON ri.Department = pd.Id
	GROUP BY ri.[Department], pd.[DepartmentName]

	--retrieve the detail data
	SELECT ri.[Department], ri.[JobTypeCodeID] AS [ID], hjt.[Description] AS [JobTitleDescription]
		, ISNULL(tps.TypeCode, N'') + N' - ' + ISNULL(htc.[Description], N'') AS [JobCategoryDescription]
		, SUM(CASE WHEN (DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate) - (CASE WHEN (DAY(ISNULL(ig.StartDate, @AsOfDate)) > DAY(@AsOfDate)) THEN 1 ELSE 0 END)) <= 5 THEN 1 ELSE 0 END) AS LessThanSix
		, SUM(CASE WHEN (DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate) - (CASE WHEN (DAY(ISNULL(ig.StartDate, @AsOfDate)) > DAY(@AsOfDate)) THEN 1 ELSE 0 END)) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS SixToYear
		, SUM(CASE WHEN (DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate) - (CASE WHEN (DAY(ISNULL(ig.StartDate, @AsOfDate)) > DAY(@AsOfDate)) THEN 1 ELSE 0 END)) BETWEEN 12 AND 59 THEN 1 ELSE 0 END) AS OneToFive
		, SUM(CASE WHEN (DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate) - (CASE WHEN (DAY(ISNULL(ig.StartDate, @AsOfDate)) > DAY(@AsOfDate)) THEN 1 ELSE 0 END)) >= 60 THEN 1 ELSE 0 END) AS MoreThanFive
		, COUNT(*) as TOTAL
		, SUM(DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate))/ 12.0 AS ServiceYears
		, SUM(DATEDIFF(MM, ISNULL(ig.StartDate, @AsOfDate), @AsOfDate))/ 12.0 / Count(*) as ALS
		, CASE @SortBy
			WHEN 0 THEN ri.[Department]
			WHEN 1 THEN hjt.[Description]
			WHEN 2 THEN htc.[Description]
			END AS GrpId1
	FROM #RptIndInfo ri
	INNER JOIN [dbo].[tblHrIndGenInfo] ig ON ri.IndID = ig.IndId
	LEFT JOIN [dbo].[tblHrJobTitle] hjt ON ri.JobTypeCodeID = hjt.ID
	LEFT JOIN [dbo].[tblHrTypeCode] htc ON hjt.JobCatTypeCodeID = htc.ID
	LEFT JOIN #StandardCodes tps ON htc.StandardID = tps.Id
	GROUP BY ri.[Department], ri.[JobTypeCodeID], hjt.[Description], htc.[Description], ISNULL(tps.TypeCode, N'') + N' - ' + ISNULL(htc.[Description], N'')

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrLongevity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrLongevity_proc';


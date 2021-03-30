
CREATE PROCEDURE [dbo].[trav_HREEOReport_proc]
@ActiveAsOfDate DATETIME,
@Summary TINYINT,
@DateFrom DATETIME,
@DateThru DATETIME,
@Active TINYINT = 2,
@SpecStat BIT = 1

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #IndividualList (IndId [dbo].[pEmpID] NOT NULL)
	INSERT INTO #IndividualList SELECT DISTINCT ind.IndId FROM tblHrIndGenInfo ind

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOfDate

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOfDate, @Active

	CREATE TABLE #TempIndividual(IndId [dbo].[pEmpID])
	IF (@SpecStat = 0)
	BEGIN
		INSERT INTO #TempIndividual
		SELECT DISTINCT ind.IndId FROM #IndividualList ind
		INNER JOIN tblHrIndGenInfo g ON ind.IndId = g.IndId
		INNER JOIN tblHrIndStatus s ON ind.IndId = s.IndId
		INNER JOIN tblHrIndPosition ip ON ind.IndId = ip.IndId
		INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
		INNER JOIN #IndStatus ins ON ins.IndId = s.IndId AND ins.StatusID = s.ID
		INNER JOIN #IndPositionID tip ON tip.IndId = ip.IndId AND tip.PositionID = ip.ID
		WHERE ((@DateFrom IS NULL OR g.StartDate >= @DateFrom) AND (@DateThru IS NULL OR g.StartDate <= @DateThru))
		AND p.SpecialStatus = 0
	END
	ELSE
	BEGIN
		INSERT INTO #TempIndividual
		SELECT DISTINCT ind.IndId FROM #IndividualList ind
		INNER JOIN tblHrIndGenInfo g ON g.IndId = ind.IndId
		INNER JOIN tblHrIndStatus s ON ind.IndId = s.IndId
		INNER JOIN tblHrIndPosition ip ON ind.IndId = ip.IndId
		INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
		INNER JOIN #IndStatus ins ON ins.IndId = s.IndId AND ins.StatusID = s.ID
		INNER JOIN #IndPositionID tip ON tip.IndId = ip.IndId AND tip.PositionID = ip.ID
		WHERE ((@DateFrom IS NULL OR g.StartDate >= @DateFrom) AND (@DateThru IS NULL OR g.StartDate <= @DateThru))
	END

	SELECT ds.SortKey, ds.EEOJobCat, ds.EEOJobCatDescr, ds.StandardDescr, ds.StandardType, ds.DivisionDescr, ds.LocationDesc, ds.ProgramDesc, ds.DeptIdDesc,
    SUM(ds.MW) AS MW,  SUM(ds.MB) AS MB,  SUM(ds.MH) AS MH,  SUM(ds.MP) AS MP,  SUM(ds.MA) AS MA,  SUM(ds.MI) AS MI,  SUM(ds.MT) AS MT,  SUM(ds.MU) AS MU,  SUM(ds.MO) AS MO,  
	SUM(ds.FW) AS FW,  SUM(ds.FB) AS FB,  SUM(ds.FH) AS FH,  SUM(ds.FP) AS FP,  SUM(ds.FA) AS FA,  SUM(ds.FI) AS FI,  SUM(ds.FT) AS FT,  SUM(ds.FU) AS FU,  SUM(ds.FO) AS FO,  
	SUM(ds.TOTAL) AS TOTAL 
	FROM (
	SELECT CASE @Summary WHEN 0 THEN N'Company' 
					WHEN 1 THEN d.Id
					WHEN 2 THEN tDiv.[Description]
					WHEN 3 THEN tLoc.[Description]
					WHEN 4 THEN tProg.[Description] END SortKey,
	cat.StandardID EEOJobCat,
	cat.[Description] EEOJobCatDescr,
	tps.[Description] StandardDescr,
	tps.TypeCode StandardType,
	CASE WHEN @Summary = 1 THEN d.DepartmentName   ELSE '' END AS DeptIdDesc,
	CASE WHEN @Summary = 2 THEN tDiv.[Description] ELSE '' END AS DivisionDescr,
	CASE WHEN @Summary = 3 THEN tLoc.[Description] ELSE '' END AS LocationDesc,
	CASE WHEN @Summary = 4 THEN tProg.[Description] ELSE '' END AS ProgramDesc,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 12 THEN 1 ELSE 0 END) AS MW,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 5 THEN 1 ELSE 0 END) AS MB,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 6 THEN 1 ELSE 0 END) AS MH,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 9 THEN 1 ELSE 0 END) AS MP,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 4 THEN 1 ELSE 0 END) AS MA,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 7 THEN 1 ELSE 0 END) AS MI,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 10 THEN 1 ELSE 0 END) AS MT,
	(CASE WHEN gender.StandardID = 22 AND ethnic.StandardID = 11 THEN 1 ELSE 0 END) AS MU,
	(CASE WHEN gender.StandardID = 21 AND ethnic.StandardID = 8 THEN 1 ELSE 0 END) AS MO,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 12 THEN 1 ELSE 0 END) AS FW,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 5 THEN 1 ELSE 0 END) AS FB,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 6 THEN 1 ELSE 0 END) AS FH,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 9 THEN 1 ELSE 0 END) AS FP,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 4 THEN 1 ELSE 0 END) AS FA,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 7 THEN 1 ELSE 0 END) AS FI,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 10 THEN 1 ELSE 0 END) AS FT,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 11 THEN 1 ELSE 0 END) AS FU,
	(CASE WHEN gender.StandardID = 20 AND ethnic.StandardID = 8 THEN 1 ELSE 0 END) AS FO,
	(CASE WHEN gender.StandardID IN (20, 21) AND ethnic.StandardID IN (11,12,5,6,9,4,7,10,8) THEN 1 ELSE 0 END) AS TOTAL

	FROM #TempIndividual x
	INNER JOIN tblHrIndGenInfo g ON x.IndId = g.IndId
	INNER JOIN #IndPositionID tp ON g.IndId = tp.IndId
	INNER JOIN dbo.tblHrIndPosition p ON tp.PositionID = p.ID
	INNER JOIN dbo.tblHrPosition po ON po.ID = p.PositionID AND p.PositionID = po.ID
	LEFT JOIN tblHrTypeCode tDiv ON po.DivisionTypeCodeID = tDiv.ID and tDiv.TableID = 24 -- TableType.PositionDivision
	LEFT JOIN tblHrTypeCode tLoc ON po.LocationTypeCodeID = tLoc.ID and tLoc.TableID = 27 --TableType.PositionLocation
	LEFT JOIN tblHrTypeCode tProg ON po.ProgramTypeCodeID = tProg.ID and tProg.TableID = 28 --TableType.PositionProgram
	LEFT JOIN tblPaDept d ON d.Id = po.Department
	LEFT JOIN dbo.tblHRJobTitle t ON po.JobTypeCodeID = t.ID
	LEFT JOIN dbo.tblHRTypeCode ethnic ON g.EthnicityTypeCodeID = ethnic.ID AND ethnic.TableID = 8
	LEFT JOIN dbo.tblHRTypeCode gender ON g.GenderTypeCodeID = gender.ID AND gender.TableID = 16
	LEFT JOIN dbo.tblHrTypeCode cat ON t.JobCatTypeCodeID = cat.ID AND cat.TableID = 19
	LEFT JOIN #TableTypeCodeStandard tps ON tps.Id = cat.StandardID AND cat.TableID = 19
	WHERE g.EthnicityTypeCodeID IS NOT NULL AND g.GenderTypeCodeID IS NOT NULL
	) ds
	GROUP BY 
	SortKey,
	ds.EEOJobCat,
	ds.EEOJobCatDescr,
	ds.StandardDescr,
	ds.StandardType,
	ds.DeptIdDesc,
	ds.DivisionDescr,
	ds.LocationDesc,
	ds.ProgramDesc

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HREEOReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HREEOReport_proc';


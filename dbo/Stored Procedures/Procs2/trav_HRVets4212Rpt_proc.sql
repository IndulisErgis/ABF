CREATE PROCEDURE [dbo].[trav_HRVets4212Rpt_proc]
@ActiveAsOfDate DATETIME,
@Summary TINYINT,
@DateFrom DATETIME,
@DateThru DATETIME,
@Active TINYINT,
@SpecStat BIT

AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #IndividualList (IndId [dbo].[pEmpID] NOT NULL)
INSERT INTO #IndividualList SELECT ind.IndId FROM tblHrIndGenInfo ind

CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOfDate

CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOfDate, @Active

SELECT ds.SortKey, ds.EEOJobCat, ds.EEOJobCatDescr, ds.StandardDescr, ds.StandardType, ds.DeptId, ds.DivisionDescr, ds.LocationDesc, ds.ProgramDesc, 
SUM(ds.DV) AS DV, SUM(ds.VV) AS VV, SUM(ds.OV) AS OV, SUM(ds.MV) AS MV, SUM(ds.RV) AS RV, SUM(ds.NV) AS NV, SUM(ds.TV) AS TV
, SUM(ds.NDV) AS NDV, SUM(ds.NVV) AS NVV, SUM(ds.NOV) AS NOV, SUM(ds.NMV) AS NMV, SUM(ds.NRV) AS NRV, SUM(ds.NNV) AS NNV, SUM(ds.NTV) AS NTV
FROM(
SELECT 
CASE @Summary WHEN 0 THEN N'Company' 
					WHEN 1 THEN p.Department
					WHEN 2 THEN divt.[Description]
					WHEN 3 THEN loct.[Description]
					WHEN 4 THEN prot.[Description] END SortKey,
cat.StandardID EEOJobCat,
cat.[Description] EEOJobCatDescr,
tps.[Description] StandardDescr,
tps.TypeCode StandardType,
CASE WHEN @Summary = 1 THEN p.Department ELSE '' END AS DeptId,
CASE WHEN @Summary = 2 THEN divt.[Description] ELSE '' END AS DivisionDescr,
CASE WHEN @Summary = 3 THEN loct.[Description] ELSE '' END AS LocationDesc,
CASE WHEN @Summary = 4 THEN prot.[Description] ELSE '' END AS ProgramDesc,
(CASE WHEN vet.StandardID = 51 THEN 1 ELSE 0 END) AS DV,
(CASE WHEN vet.StandardID = 56 THEN 1 ELSE 0 END) AS VV,
(CASE WHEN vet.StandardID = 54 THEN 1 ELSE 0 END) AS OV,
(CASE WHEN vet.StandardID = 52 THEN 1 ELSE 0 END) AS MV,
(CASE WHEN vet.StandardID = 55 THEN 1 ELSE 0 END) AS RV,
(CASE WHEN vet.StandardID = 53 THEN 1 ELSE 0 END) AS NV,
(CASE WHEN vet.StandardID IN (51,52,53,54,55,56) THEN 1 ELSE 0 END) AS TV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 51 THEN 1 ELSE 0 END) AS NDV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 56 THEN 1 ELSE 0 END) AS NVV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 54 THEN 1 ELSE 0 END) AS NOV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 52 THEN 1 ELSE 0 END) AS NMV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 55 THEN 1 ELSE 0 END) AS NRV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID = 53 THEN 1 ELSE 0 END) AS NNV,
(CASE WHEN g.StartDate BETWEEN @DateFrom AND @DateThru AND vet.StandardID IN (51,52,53,54,55,56) THEN 1 ELSE 0 END) NTV

FROM tblHrPosition p
INNER JOIN tblHrIndPosition ip ON ip.PositionID = p.ID
INNER JOIN #IndPositionID tpos ON tpos.IndId = ip.IndId AND tpos.PositionID = ip.ID
INNER JOIN #IndStatus ts ON tpos.IndId = ts.IndId
INNER JOIN dbo.tblHRIndGenInfo g ON ip.IndId = g.IndId
INNER JOIN dbo.tblPaDept d ON d.Id = p.Department
LEFT JOIN dbo.tblHRJobTitle t ON p.JobTypeCodeID = t.ID
LEFT JOIN dbo.tblHrTypeCode divt ON p.DivisionTypeCodeID = divt.ID AND divt.TableID = 24
LEFT JOIN dbo.tblHrTypeCode prot ON p.ProgramTypeCodeID = prot.ID AND prot.TableID = 28
LEFT JOIN dbo.tblHrTypeCode loct ON p.LocationTypeCodeID = loct.ID AND loct.TableID = 27
LEFT JOIN dbo.tblHRTypeCode vet ON g.VeteranStatusTypeCodeID = vet.ID AND vet.TableID = 36
LEFT JOIN dbo.tblHrTypeCode cat ON t.JobCatTypeCodeID = cat.ID AND cat.TableID = 19
LEFT JOIN #TableTypeCodeStandard tps ON tps.Id = cat.StandardID AND cat.TableID = 19
WHERE g.VeteranStatusTypeCodeID IS NOT NULL AND (p.SpecialStatus = 0 OR @SpecStat = 1) 
AND ((@DateFrom IS NULL OR g.StartDate >= @DateFrom) AND (@DateThru IS NULL OR g.StartDate <= @DateThru)) --non-"special" or include all status
) ds

GROUP BY 
SortKey,
DS.EEOJobCat,
DS.EEOJobCatDescr,
DS.StandardDescr,
DS.StandardType,
DS.DeptId,
DS.DivisionDescr,
DS.LocationDesc,
DS.ProgramDesc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRVets4212Rpt_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRVets4212Rpt_proc';


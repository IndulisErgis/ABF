CREATE PROCEDURE [dbo].[trav_HRIndLabelsReport_proc]
@Date DATE,
@DeptIDFrom dbo.pDeptID,
@DeptIDThru dbo.pDeptID,
@IndStatus SMALLINT

AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @Date

CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID bigint NULL,[IndStatus] tinyint NULL)
INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @Date, @IndStatus

SELECT ds.IndId,ds.FullName,ds.Address1,ds.Address2, ds.City, ds.State, ds.ZipCode, ds.CountryCode, ds.Department, ds.Manager
	FROM (
	SELECT ind.IndId, (ISNULL(ind.LastName,'') + ', ' + ISNULL(ind.FirstName,'') + ' ' + ISNULL(ind.MiddleInit,'')) AS FullName, ind.Address1, ind.Address2, 
		ind.City, ind.State, ind.ZipCode, ind.CountryCode, p.Department, (ISNULL(m.LastName,'') + ', ' + ISNULL(m.FirstName,'') + ' ' + ISNULL(m.MiddleInit,'')) AS Manager
	FROM dbo.tblHrIndGenInfo ind 
		LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId]
		INNER JOIN #IndPositionID ip ON ip.[IndId] = ind.[IndId]
		LEFT JOIN tblHrIndPosition inp ON inp.[ID] = ip.[PositionID] 
		LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID]
		LEFT JOIN dbo.tblHrIndGenInfo m ON m.[IndId] = ind.Manager 
	WHERE (@DeptIDFrom IS NULL OR @DeptIDThru IS NULL OR (p.Department BETWEEN @DeptIDFrom AND @DeptIDThru)))ds
INNER JOIN #IndividualList il ON il.IndId = ds.IndId 

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndLabelsReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndLabelsReport_proc';


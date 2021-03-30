CREATE PROCEDURE [dbo].[trav_HrIndHealth_proc]
@AsOfDate DATE,
@Status TINYINT,
@DepartmentFrom [pDeptId],
@DepartmentThru [pDeptId],
@SortBy INT

AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL, [IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @AsOfDate, @Status 

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @AsOfDate

	SELECT DISTINCT 
	CASE
		WHEN @SortBy = 0 THEN hins.[Description]
		WHEN @SortBy = 1 THEN p.Department
		WHEN @SortBy = 2 THEN ind.Manager
	END AS SortBy,
	indh.ID, indh.HealthInsID, p.Department, ind.Manager, ind.IndId, (ind.LastName + ', ' + ind.FirstName) AS Name, indh.PolicyNumber, 
	hins.EmployerContribution, hins.EmployeeContribution, hins.[Description], hins.GroupNumber
	FROM tblHrIndHealth indh
	INNER JOIN tblHrHealthInsurance hins ON hins.ID = indh.HealthInsID
	INNER JOIN tblHrIndGenInfo ind ON ind.IndId = indh.IndId
	INNER JOIN tblHrIndPosition ip ON ip.IndId = ind.IndId
	INNER JOIN #IndStatus ins ON ins.IndId = indh.IndId
	INNER JOIN #IndPositionID tip ON tip.IndId = indh.IndId AND tip.PositionID = ip.ID
	INNER JOIN tblHrPosition p ON p.ID = ip.PositionID
	INNER JOIN #tmpHealthInsPlan tmp ON tmp.ID = hins.ID
	WHERE @DepartmentFrom IS NULL OR @DepartmentThru IS NULL OR (p.Department BETWEEN @DepartmentFrom AND @DepartmentThru)

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndHealth_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndHealth_proc';


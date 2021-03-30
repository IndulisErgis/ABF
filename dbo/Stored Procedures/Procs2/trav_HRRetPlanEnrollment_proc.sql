CREATE PROCEDURE [dbo].[trav_HRRetPlanEnrollment_proc]
@ActiveAsOfDate DATETIME,
@Status TINYINT,
@DeptIDFrom pDeptID,
@DeptIDThru pDeptID,
@SortBy TINYINT

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT ds.IndId INTO #IndividualList FROM (SELECT * FROM tblHrIndGenInfo) ds

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @ActiveAsOfDate

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL,[IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @ActiveAsOfDate, @Status

	SELECT DISTINCT CASE @SortBy WHEN 0 THEN r.[Description]
				WHEN 1 THEN hp.Department
				WHEN 2 THEN i.Manager END AS SortBy, 
    hp.Department, pd.DepartmentName, i.Manager, r.[Description], i.IndId, r.ID as RetPlanID, (i.LastName + ', ' + i.FirstName) AS Name,
	m.[Description] AS [PremiumMethod], ir.PreTaxNumber, ir.AfterTaxNumber, ir.BonusNumber, ir.LoanAmount, r.AccountNumber
	FROM dbo.tblHrRetirementPlan r
	INNER JOIN tblHrIndRetirement ir ON r.ID = ir.RetPlanID
	INNER JOIN tblHrIndGenInfo i ON i.IndId = ir.IndId
	INNER JOIN #tmpRetirementPlan p ON ir.RetPlanID = p.ID
	INNER JOIN tblHrIndPosition ip ON ip.IndId = i.IndId
	INNER JOIN tblHrIndStatus s ON s.IndId = i.IndId
	INNER JOIN #IndPositionID tpos ON tpos.IndId = ip.IndId AND tpos.PositionID = ip.ID
	INNER JOIN #IndStatus ts ON tpos.IndId = ts.IndId
	INNER JOIN tblHrPosition hp ON hp.ID = ip.PositionID
	LEFT JOIN tblPaDept pd ON hp.Department = pd.Id
	LEFT JOIN dbo.tblHRTypeCode m ON ir.AllocMethodTypeCodeID = m.ID AND m.TableID = 29
	WHERE (@DeptIDFrom IS NULL OR @DeptIDThru IS NULL OR (hp.Department BETWEEN @DeptIDFrom AND @DeptIDThru))

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRRetPlanEnrollment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRRetPlanEnrollment_proc';


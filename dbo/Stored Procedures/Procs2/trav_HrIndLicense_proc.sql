CREATE PROCEDURE [dbo].[trav_HrIndLicense_proc]
@Department [pDeptId],
@LicenseType [bigint],
@ExpDate DATE,
@WksDate DATE

AS
SET NOCOUNT ON
BEGIN TRY
	
	DECLARE @now DATE
	SET @now = GETDATE()
	
	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID bigint NULL, [IndStatus] tinyint NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @now, 0 

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @now, 1

	SELECT DISTINCT IndId, IndividualName, [IndStatus], [Department], [DepartmentName], Manager,  ManagerName, PositionStatus, PositionDescription, LicenseType, LicenseExpDate 
	FROM(SELECT ind.IndId, ins.[IndStatus], p.[Department], d.[DepartmentName], ind.Manager,
	(SELECT CASE WHEN
		(p.PositionActiveDate IS NULL OR @WksDate >= p.PositionActiveDate) AND 
		(p.PositionInactiveDate > @WksDate OR p.PositionInactiveDate IS NULL) THEN 1 ELSE 0 END) [PositionStatus],
	p.[Description] [PositionDescription], li.LicenseTypeCodeID [LicenseID], t.Description [LicenseType], LicenseExpDate,
	CASE 
		WHEN (ind.LastName IS NULL OR ind.LastName = '') THEN ind.FirstName 
		WHEN (ind.FirstName IS NULL OR ind.FirstName = '') THEN ind.LastName ELSE (ind.LastName + ',' + SPACE(1) + ind.FirstName) END [IndividualName],
	CASE 
		WHEN (im.LastName IS NULL OR im.LastName = '') THEN im.FirstName
		WHEN (im.FirstName IS NULL OR im.LastName = '') THEN im.LastName ELSE (im.LastName + ',' + SPACE(1) + im.FirstName) END [ManagerName] 
	FROM dbo.tblHrIndGenInfo ind 
	INNER JOIN #IndividualList il ON il.[IndId] = ind.[IndId]
	INNER JOIN tblHrIndLicense li ON li.IndId = ind.IndId
	LEFT JOIN tblHrIndPosition inp ON inp.IndId = ind.IndId
	LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId] 
	LEFT JOIN #IndPositionID ip ON ip.IndId = inp.IndId AND ip.PositionID = inp.ID
	LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID] 
	LEFT JOIN tblPaDept d ON d.[Id] = p.[Department] 
	LEFT JOIN tblHrIndGenInfo im ON im.[IndId] = ind.Manager 
	LEFT JOIN tblHrTypeCode t ON t.ID = li.LicenseTypeCodeID
	)
	ds 
	WHERE 
	(@LicenseType IS NULL OR @LicenseType = LicenseID) AND
	(@Department IS NULL OR @Department = [Department]) AND
	(@ExpDate IS NULL OR @ExpDate >= LicenseExpDate)

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndLicense_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndLicense_proc';


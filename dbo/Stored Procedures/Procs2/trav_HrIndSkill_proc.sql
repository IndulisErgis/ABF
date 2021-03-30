CREATE PROCEDURE [dbo].[trav_HrIndSkill_proc]
@Department [pDeptId],
@SkillsType [bigint],
@Hours [pDecimal],
@DateAcquiredFrom DATE,
@DateAcquiredThru DATE

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @now DATE
	SET @now = GETDATE()

	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID bigint NULL, [IndStatus] tinyint NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @now, 0 

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @now

		SELECT DISTINCT IndId, IndividualName, City, CountryCode, HomePhone, CellPhone, BusinessPhone, [State], 
		StartDate, ZipCode, DOB, IndStatus, [Department], DepartmentName, Manager, [ManagerName], [SkillDescription], DateAcquired, [Hours], [Notes] 
		FROM(SELECT ind.IndId, ind.City, ind.CountryCode, ind.HomePhone, ind.CellPhone, ind.BusinessPhone, ind.[State], 
		ind.StartDate, ind.ZipCode, ind.DOB, ins.IndStatus, p.[Department], d.DepartmentName, ind.Manager, 
		ISNULL(im.LastName, N'') + N' ' + ISNULL(im.FirstName, N'') AS [ManagerName], sk.DateAcquired, sk.[Hours], sk.[Notes], sk.[SkillTypeCodeID], tc.[Description] [SkillDescription],
		CASE 
			WHEN (ind.LastName IS NULL OR ind.LastName = N'') THEN ind.FirstName 
			WHEN (ind.FirstName IS NULL OR ind.FirstName = N'') THEN ind.LastName ELSE (ind.LastName + N', ' + ind.FirstName) END [IndividualName]
		FROM dbo.tblHrIndGenInfo ind
		INNER JOIN #IndividualList il ON il.[IndId] = ind.[IndId] 
		LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId] 
		LEFT JOIN #IndPositionID ip ON ip.[IndId] = ind.[IndId] 
		LEFT JOIN tblHrIndPosition inp ON inp.[ID] = ip.[PositionID] 
		LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID] 
		LEFT JOIN tblPaDept d ON d.[Id] = p.[Department] 
		LEFT JOIN tblHrIndGenInfo im ON im.[IndId] = ind.Manager 
		INNER JOIN tblHrIndSkill sk ON sk.IndId = ind.IndId
		INNER JOIN tblHrTypeCode tc ON tc.ID = sk.[SkillTypeCodeID]
		)ds
		WHERE 
		(@SkillsType IS NULL OR @SkillsType = [SkillTypeCodeID]) 
		AND (@Department IS NULL OR @Department = [Department]) 
		AND (@Hours IS NULL OR @Hours >= [Hours]) 
		AND ((@DateAcquiredFrom IS NULL OR [DateAcquired] >= @DateAcquiredFrom) 
			AND (@DateAcquiredThru IS NULL OR [DateAcquired] <= @DateAcquiredThru))

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndSkill_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndSkill_proc';


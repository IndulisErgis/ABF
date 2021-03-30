
--PET: http://problemtrackingsystem.osas.com/view.php?id=268235
--PET: http://problemtrackingsystem.osas.com/view.php?id=267980

CREATE PROCEDURE [dbo].[trav_HrPositionAssignmentView_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @EffectiveDate DATETIME = CONVERT(DATE, GETDATE())
	CREATE TABLE #SupervisorList ([PositionId] [bigint] NOT NULL, [IndId] [pEmpID] NULL)
	INSERT INTO #SupervisorList EXEC [trav_HrPositionActiveSupervisor_proc] @EffectiveDate

	SELECT * FROM(
	SELECT DISTINCT IndId, CASE 
		WHEN CurrentStatus = 0 THEN ''
		WHEN (LastName IS NULL OR LastName = '') THEN FirstName 
		WHEN (FirstName IS NULL OR FirstName = '') THEN LastName ELSE (LastName + ',' + SPACE(1) + FirstName) END [IndividualName],
	City, CountryCode, HomePhone, CellPhone, BusinessPhone, [State], [StartDateInd],
	ZipCode, DOB, [IndStatus], [PositionID], [SpecialStatus], [SupervisorPositionID], [Department], [DepartmentName], 
	Manager, [ManagerName], [PositionDescription], [PositionType], [HoursBudgeted], [SalaryBudgeted], [CurrentStatus],
	[PositionStatus], [SupervisorPositionDescription], [SupervisorId], [SupervisorName], StartDate, EndDate, PrimaryPosition
	FROM(SELECT ROW_NUMBER() OVER(PARTITION BY p.[Description] ORDER BY inp.[ID] DESC) [rn], ind.IndId, ind.LastName, ind.FirstName, ind.City, 
	ind.CountryCode, ind.HomePhone, ind.CellPhone, ind.BusinessPhone, ind.[State], ind.StartDate [StartDateInd], ind.ZipCode, 
	ind.DOB, ins.[IndStatus], p.[Department], d.[DepartmentName], ind.Manager, p.[Description] [PositionDescription], tcpos.[Description] [PositionType], 
	p.PositionHoursBudgeted [HoursBudgeted], p.SalaryBudgeted, p.ID AS [PositionID], p.SpecialStatus, pp.ID [SupervisorPositionID],
	(CASE WHEN 
		(inp.StartDate IS NULL OR CONVERT(DATE, GETDATE()) >= inp.StartDate) AND (inp.EndDate IS NULL OR CONVERT(DATE, GETDATE()) <= inp.EndDate) AND ins.IndStatus = 1 THEN 1 ELSE 0 END
	) [CurrentStatus],
	(SELECT CASE WHEN
		(p.PositionActiveDate IS NULL OR CONVERT(DATE,GETDATE()) >= p.PositionActiveDate) AND 
		(p.PositionInactiveDate > CONVERT(DATE,GETDATE()) OR p.PositionInactiveDate IS NULL) THEN 1 ELSE 0 END) [PositionStatus],
	pp.[Description] [SupervisorPositionDescription], ips.IndId AS SupervisorId,
	CASE 
		WHEN (im.LastName IS NULL OR im.LastName = '') THEN im.FirstName
		WHEN (im.FirstName IS NULL OR im.LastName = '') THEN im.LastName ELSE (im.LastName + ',' + SPACE(1) + im.FirstName) END [ManagerName], 
	CASE 
		WHEN (ips.LastName IS NULL OR ips.LastName = '') THEN ips.FirstName
		WHEN (ips.FirstName IS NULL OR ips.LastName = '') THEN ips.LastName ELSE (ips.LastName + ',' + SPACE(1) + ips.FirstName) END [SupervisorName], inp.StartDate, inp.EndDate, inp. PrimaryPosition
	FROM dbo.tblHrIndGenInfo ind
	LEFT JOIN dbo.tblSmEmployee emp ON ind.IndId = emp.EmployeeId
	LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId] 
	INNER JOIN tblHrIndPosition inp ON inp.[IndId] = ind.[IndId]
	INNER JOIN #PositionAssignmentList pal ON pal.ID = inp.[PositionID]
	LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID]
	LEFT JOIN tblHrPosition pp ON pp.[ID] = p.SupervisorPositionID
	LEFT JOIN #SupervisorList s ON s.PositionId = p.SupervisorPositionID
	LEFT JOIN tblHrIndGenInfo ips ON ips.IndId = s.IndId
	LEFT JOIN tblHrTypeCode tcpos ON tcpos.ID = p.PositionTypeCodeID
	LEFT JOIN tblPaDept d ON d.[Id] = p.[Department] 
	LEFT JOIN tblHrIndGenInfo im ON im.[IndId] = ind.Manager 
	WHERE ISNULL(emp.[Status], 0) = 0
	)ds WHERE (CurrentStatus = 1 OR (CurrentStatus = 0 AND rn = 1)))da

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionAssignmentView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrPositionAssignmentView_proc';


CREATE PROCEDURE [dbo].[trav_HRIndTrainingReport_proc]
@IncludeAll BIT,
@Date DATE,
@DepID dbo.pDeptID,
@TrainingID BIGINT,
@DateAcqFrom DATE,
@DateAcqThru DATE,
@Hours INT

AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @Date

CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID bigint NULL,[IndStatus] tinyint NULL)
INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @Date, 0

SELECT * FROM(
	SELECT DISTINCT IndId, IndividualName, City, CountryCode, HomePhone, CellPhone, BusinessPhone, State, StartDateInd, ZipCode, DOB, IndStatus, Department, DepartmentName
	, Manager, ManagerName, SpecialStatus, TrainingType,TrainingDescription, Approver, Notes, DateAcquired, Hours, TravelCost, EventCost, SUM(Hours) OVER(PARTITION BY IndId) AS SumHours, TrainingID
	FROM(
		SELECT ind.IndId, ind.LastName, ind.FirstName, ind.City, ind.CountryCode, ind.HomePhone, ind.CellPhone, ind.BusinessPhone, ind.State, 
		ind.StartDate AS StartDateInd, ind.ZipCode, ind.DOB,ins.IndStatus, tr.DeptId [Department], d.DepartmentName, 
				ind.Manager, CAST(CASE WHEN p.SpecialStatus IS NULL THEN 0 ELSE p.SpecialStatus END AS bit) [SpecialStatus],
				tr.TrainingCodeID [TrainingID], tc.Description [TrainingDescription], tr.DateAcquired, tr.Hours, tr.DeptId,
				 tco.Description [TrainingType],   tr.Approver, 
					 tr.Notes,   tr.TravelCost, tr.EventCost,tr.TrainingCodeID ,
		CASE 
			WHEN (ind.LastName IS NULL OR ind.LastName = '') THEN ind.FirstName 
			WHEN (ind.FirstName IS NULL OR ind.FirstName = '') THEN ind.LastName ELSE (ind.LastName + ',' + SPACE(1) + ind.FirstName) END [IndividualName],
		CASE 
			WHEN (im.LastName IS NULL OR im.LastName = '') THEN im.FirstName
			WHEN (im.FirstName IS NULL OR im.LastName = '') THEN im.LastName ELSE (im.LastName + ',' + SPACE(1) + im.FirstName) END [ManagerName]
		FROM dbo.tblHrIndGenInfo ind
		LEFT JOIN #IndStatus ins ON ins.[IndId] = ind.[IndId] 
		LEFT JOIN #IndPositionID ip ON ip.[IndId] = ind.[IndId] 
		LEFT JOIN tblHrIndPosition inp ON inp.[ID] = ip.[PositionID] 
		LEFT JOIN tblHrPosition p ON p.[ID] = inp.[PositionID] 
		LEFT JOIN tblHrIndGenInfo im ON im.[IndId] = ind.Manager 
		LEFT JOIN dbo.tblHrIndTraining tr ON ind.IndId = tr.IndId 
		LEFT JOIN tblPaDept d ON d.[Id] = tr.DeptId
		LEFT JOIN tblHrTypeCode tc ON tr.TrainingCodeID = tc.ID 
		LEFT JOIN tblHrTypeCode tco ON tr.TrainingTypeID = tco.ID
		) ds 
		WHERE (@DepID IS NULL OR DeptId = @DepID) AND (@TrainingID IS NULL OR TrainingID = @TrainingID) AND (@DateAcqFrom IS NULL OR DateAcquired >= @DateAcqFrom) 
		AND (@DateAcqThru IS NULL OR DateAcquired <= @DateAcqThru) OR TrainingID IS NULL) data
		WHERE (@Hours = 0 OR data.SumHours <= @Hours OR (@IncludeAll = 1 AND data.TrainingID IS NULL)) AND
		data.IndId IN (SELECT li.IndId 
					    FROM #IndividualList li 
						LEFT JOIN dbo.tblHrIndTraining tr ON tr.IndId = li.IndId WHERE (@IncludeAll = 1 OR tr.ID IS NOT NULL)) 

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndTrainingReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndTrainingReport_proc';


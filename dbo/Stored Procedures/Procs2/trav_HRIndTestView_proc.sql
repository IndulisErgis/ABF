CREATE PROCEDURE [dbo].[trav_HRIndTestView_proc]
@Date DATE,
@DepID dbo.pDeptID,
@TestID BIGINT, 
@DivisionID BIGINT,
@LocationID BIGINT,
@ProgramID BIGINT, 
@RecDateFrom DATE, 
@RecDateThru DATE,
@IncludeIndividuals bit

AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @Date

CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID bigint NULL,[IndStatus] tinyint NULL)
INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @Date, 0

SELECT * FROM (
SELECT DISTINCT IndId, IndStatus, IndividualName, Department,
		DepartmentName, Manager, ManagerName, PositionStatus, PositionDivision,PositionLocation,PositionProgram, TestDescription, DateAcquired, Score, RecertificationDate
		FROM(
			SELECT ind.IndId, ind.City, ind.CountryCode, ind.HomePhone, ind.CellPhone,
				ind.BusinessPhone, ind.State, ind.StartDate [StartDateInd], ind.ZipCode, ind.DOB, ins.IndStatus,
				p.Department, d.DepartmentName, ind.Manager, dtc.ID [DivisionID], dtc.Description [PositionDivision], ptc.ID [ProgramID], 
				ptc.Description [PositionProgram], ltc.ID [LocationID], ltc.Description [PositionLocation],te.Description [TestDescription], te.ID [TestID], ite.DateAcquired, ite.Score,
				 ite.RecertificationDate, 
				(SELECT CASE WHEN
					(p.PositionActiveDate IS NULL OR @Date >= p.PositionActiveDate) AND 
					(p.PositionInactiveDate > @Date OR p.PositionInactiveDate IS NULL) THEN 1 ELSE 0 END) [PositionStatus],
				CASE 
					WHEN (ind.LastName IS NULL OR ind.LastName = '') THEN ind.FirstName 
					WHEN (ind.FirstName IS NULL OR ind.FirstName = '') THEN ind.LastName ELSE (ind.LastName + ',' + SPACE(1) + ind.FirstName) END [IndividualName],
				CASE 
					WHEN (im.LastName IS NULL OR im.LastName = '') THEN im.FirstName
					WHEN (im.FirstName IS NULL OR im.LastName = '') THEN im.LastName ELSE (im.LastName + ',' + SPACE(1) + im.FirstName) END [ManagerName]
		FROM dbo.tblHrIndGenInfo ind 
		LEFT JOIN #IndStatus ins ON ins.[IndId]=ind.[IndId] 
		LEFT JOIN #IndPositionID ip ON ip.[IndId]=ind.[IndId] 
		LEFT JOIN dbo.tblHrIndPosition inp ON inp.IndId =ip.IndId AND INP.ID = IP.PositionID
		LEFT JOIN dbo.tblHrPosition p ON p.[ID]=inp.[PositionID] 
		LEFT JOIN dbo.tblHrIndTest ite ON ite.IndId=ind.IndId 
		LEFT JOIN dbo.tblPaDept d ON d.[Id]=p.[Department] 
		LEFT JOIN dbo.tblHrIndGenInfo im ON im.[IndId]=ind.Manager 
		LEFT JOIN dbo.tblHrTypeCode dtc ON p.DivisionTypeCodeID=dtc.ID 
		LEFT JOIN dbo.tblHrTypeCode ptc ON p.ProgramTypeCodeID=ptc.ID 
		LEFT JOIN dbo.tblHrTypeCode ltc ON p.LocationTypeCodeID=ltc.ID 
		LEFT JOIN dbo.tblHRTestType te ON te.ID=ite.TestTypeID)ds 
	WHERE (@DepID IS NULL OR @DepID = Department) AND (@DivisionID IS NULL OR @DivisionID = DivisionID)
		AND (@TestID IS NULL OR @TestID = TestID OR (TestId IS NULL AND @IncludeIndividuals = 1)) AND (@LocationID IS NULL OR @LocationID = LocationID) AND (@ProgramID IS NULL OR @ProgramID = ProgramID)
		AND ((@RecDateFrom IS NULL OR RecertificationDate >= @RecDateFrom) AND (@RecDateThru IS NULL OR RecertificationDate <= @RecDateThru) OR (TestId IS NULL AND @IncludeIndividuals = 1))
		AND (@IncludeIndividuals = 1 OR (@IncludeIndividuals = 0 AND ds.TestID IS NOT NULL))) data
INNER JOIN #IndividualList ind ON ind.IndId = data.IndId

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndTestView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HRIndTestView_proc';


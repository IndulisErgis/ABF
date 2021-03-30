CREATE PROCEDURE [dbo].[trav_HrIndSalaryByPosition_proc]
@AsOfDate DATE,
@Status TINYINT,
@DepartmentFrom [pDeptId],
@DepartmentThru [pDeptId],
@JobIdFrom NVARCHAR(100),
@JobIdThru NVARCHAR(100),
@SortBy INT

AS
SET NOCOUNT ON
BEGIN TRY
	
	CREATE TABLE #IndStatus (IndId [dbo].[pEmpID] NOT NULL, StatusID BIGINT NULL, [IndStatus] TINYINT NULL)
	INSERT INTO #IndStatus EXEC [trav_HrIndEffectiveStatus_proc] @AsOfDate, @Status 

	CREATE TABLE #IndPositionID (IndId [dbo].[pEmpID], PositionID [bigint])
	INSERT INTO #IndPositionID EXEC [trav_HrIndEffectivePosition_proc] @AsOfDate

	SELECT * INTO #IndSalary FROM (SELECT DISTINCT 
	ROW_NUMBER() OVER(PARTITION BY ind.IndId ORDER BY s.EffectiveDate DESC) AS rn,
	CASE
		WHEN @SortBy = 0 THEN ind.IndId
		WHEN @SortBy = 1 THEN jt.[Description]
		WHEN @SortBy = 2 THEN p.Department
		WHEN @SortBy = 3 THEN ind.Manager
	END AS SortBy, s.ID,
	ind.IndId, (ind.LastName + ', ' + ind.FirstName) AS Name, jt.[Description] AS JobCode,
	p.Department, ind.Manager,
	(CASE
		WHEN tcs.StandardId=24 THEN 'AFT'
		WHEN tcs.StandardId=25 THEN 'APT'
		WHEN tcs.StandardId=26 THEN 'DEC'
		WHEN tcs.StandardId=27 THEN 'NEM'
		WHEN tcs.StandardId=28 THEN 'RET'
		WHEN tcs.StandardId=29 THEN 'TER'
	END) AS IndividualStatus, 
	(DATEDIFF(MM,inp.StartDate, GETDATE())/12.0) AS YearsInPosition,
	(CASE WHEN s.PayType=0 THEN 'Hourly' ELSE 'Salaried' END) AS PayType, s.Salary, s.HourlyRate, s.ExemptFromOvertime 
	FROM tblHrIndGenInfo ind
	INNER JOIN #IndStatus tis ON tis.IndId = ind.IndId
	LEFT JOIN tblHrIndStatus ins ON ins.ID = tis.StatusID
	LEFT JOIN tblHrTypeCode tcs ON tcs.ID = ins.IndStatusTypeCodeID
	INNER JOIN #IndPositionID tip ON tip.IndId = ind.IndId
	LEFT JOIN tblHrIndPosition inp ON inp.ID = tip.PositionID
	LEFT JOIN tblHrPosition p On p.ID = inp.PositionID
	LEFT JOIN tblHrJobTitle jt ON jt.ID = p.JobTypeCodeID
	INNER JOIN tblHrIndSalary s ON s.IndId = ind.IndId
	WHERE (@DepartmentFrom IS NULL OR @DepartmentThru IS NULL OR [Department] BETWEEN @DepartmentFrom AND @DepartmentThru) AND
	(@JobIdFrom IS NULL OR @JobIdThru IS NULL OR jt.[Description] BETWEEN @JobIdFrom AND @JobIdThru))ds WHERE rn=1

	SELECT SortBy, IndId, Name, JobCode, Department, Manager,IndividualStatus, YearsInPosition, PayType, Salary, HourlyRate, ExemptFromOvertime FROM #IndSalary

	SELECT AVG(s.Salary) AS AverageSalary, SUM(s.Salary) AS TotalSalary, AVG(CONVERT(decimal,ins.YearsInPosition)) AS AverageYears, COUNT(DISTINCT ins.IndId) AS Employees
	FROM tblHrIndSalary s
	INNER JOIN #IndSalary ins ON ins.IndId = s.IndId AND s.ID = ins.ID

END TRY

BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndSalaryByPosition_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_HrIndSalaryByPosition_proc';


CREATE PROCEDURE [dbo].[trav_PcEmployeeDetailHistReport_proc]
@StartDate Datetime,
@EndDate Datetime = null,
@EmployeeId varchar(50)

AS
BEGIN TRY
SET NOCOUNT ON
	        SELECT d.Id as ID ,a.ResourceId AS EmployeeId
            , COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '')  + ' ' + COALESCE (MiddleInit, '') AS EmployeeName
            , p.CustId, c.CustName, a.ActivityDate
            , p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, a.[Description] as Descrption , a.[AddnlDesc] as AdditionalDescription
            , p.[Description] AS ProjectDescr, ph.[Description] AS PhaseDescr
            , CASE WHEN d.TaskId IS NULL THEN NULL ELSE d.[Description] END AS TaskDescr
			 , a.Qty AS [Hours]
            , a.ExtIncome AS Income
            , a.ExtCost AS Cost
            , a.ExtIncome - a.ExtCost AS Profit
            , (CASE a.ExtIncome WHEN 0 THEN 0 ELSE (a.ExtIncome - a.ExtCost) / a.ExtIncome END) * 100.00 AS [Percent]
            , p.ProjectName, d.ProjectManager, p.Billable, d.[Status], d.Rep1Id, d.Rep2Id
            , a.[Status] AS ActivityStatus, a.SourceReference, e.LastName, e.FirstName 
      FROM dbo.tblPcActivity a 
            LEFT JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
            LEFT JOIN dbo.trav_PcProject_View p ON d.ProjectId = p.Id 
            LEFT JOIN dbo.tblPcPhase ph ON d.PhaseId = ph.PhaseId 
            LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId 
            LEFT JOIN dbo.tblSmEmployee e ON a.ResourceId = e.EmployeeId
      WHERE (a.[Status] BETWEEN 1 AND 5) AND a.[Type] = 0
AND (ActivityDate between @StartDate and @EndDate 
OR ActivityDate >= case when @EndDate is null then @StartDate else null end)
AND a.ResourceId = @EmployeeId
order by ID ,ActivityDate asc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcEmployeeDetailHistReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcEmployeeDetailHistReport_proc';



CREATE PROCEDURE dbo.trav_PcEmployeeDetailList_proc
@FiscalYear smallint,
@FiscalPeriod smallint
AS
BEGIN TRY
SET NOCOUNT ON
	SELECT t.EmployeeId, ISNULL(e.FirstName, '') + ' ' + ISNULL(e.MiddleInit, '') + ' ' + ISNULL(e.LastName, '') EmployeeName,
			ISNULL(s.MTDBillableHours,0) AS MTDBillableHours,
			ISNULL(s.MTDBillableCost,0) AS MTDBillableCost,
			ISNULL(s.MTDBillableAmt,0) AS MTDBillableAmt,
			ISNULL(s.MTDNonBillableHours,0) AS MTDNonBillableHours,
			ISNULL(s.MTDNonBillableCost,0) AS MTDNonBillableCost,
			ISNULL(s.MTDSpecHours,0) AS MTDSpecHours,
			ISNULL(s.MTDSpecCost,0) AS MTDSpecCost,
			ISNULL(s.MTDSpecInc,0) AS MTDSpecInc,
			ISNULL(s.MTDAdminHours,0) AS MTDAdminHours,
			ISNULL(s.MTDAdminCost,0) AS MTDAdminCost,		
			ISNULL(s.MTDJobCostHours,0) AS MTDJobCostHours,
			ISNULL(s.MTDJobCostCost,0) AS MTDJobCostCost,		
			ISNULL(s.MTDTotalHours,0) AS MTDTotalHours,
			ISNULL(s.MTDTotalCost,0) AS MTDTotalCost,
			ISNULL(s.MTDTotalAmt,0) AS MTDTotalAmt,
			ISNULL(s.YTDBillableHours,0) AS YTDBillableHours,
			ISNULL(s.YTDBillableCost,0) AS YTDBillableCost,
			ISNULL(s.YTDBillableAmt,0) AS YTDBillableAmt,
			ISNULL(s.YTDNonBillableHours,0) AS YTDNonBillableHours,
			ISNULL(s.YTDNonBillableCost,0) AS YTDNonBillableCost,
			ISNULL(s.YTDSpecHours,0) AS YTDSpecHours,
			ISNULL(s.YTDSpecCost,0) AS YTDSpecCost,
			ISNULL(s.YTDSpecInc,0) AS YTDSpecInc,
			ISNULL(s.YTDAdminHours,0) AS YTDAdminHours,
			ISNULL(s.YTDAdminCost,0) AS YTDAdminCost,		
			ISNULL(s.YTDJobCostHours,0) AS YTDJobCostHours,
			ISNULL(s.YTDJobCostCost,0) AS YTDJobCostCost,		
			ISNULL(s.YTDTotalHours,0) AS YTDTotalHours,
			ISNULL(s.YTDTotalCost,0) AS YTDTotalCost,
			ISNULL(s.YTDTotalAmt,0) AS YTDTotalAmt	
	FROM #tmpEmployeeList t INNER JOIN dbo.tblSmEmployee e ON t.EmployeeId = e.EmployeeId 
		LEFT JOIN	
		(SELECT t.EmployeeId, SUM(CASE WHEN d.Billable = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDBillableHours,
			SUM(CASE WHEN d.Billable = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDBillableCost,
			SUM(CASE WHEN d.Billable = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtIncome ELSE 0 END) AS MTDBillableAmt,
			SUM(CASE WHEN d.Billable = 0 AND a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDNonBillableHours,
			SUM(CASE WHEN d.Billable = 0 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDNonBillableCost,
			SUM(CASE WHEN d.Speculative = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDSpecHours,
			SUM(CASE WHEN d.Speculative = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDSpecCost,
			SUM(CASE WHEN d.Speculative = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtIncome ELSE 0 END) AS MTDSpecInc,
			SUM(CASE WHEN p.[Type] = 2 AND a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDAdminHours,
			SUM(CASE WHEN p.[Type] = 2 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDAdminCost,		
			SUM(CASE WHEN p.[Type] = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDJobCostHours,
			SUM(CASE WHEN p.[Type] = 1 AND a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDJobCostCost,		
			SUM(CASE WHEN a.FiscalPeriod = @FiscalPeriod THEN a.Qty ELSE 0 END) AS MTDTotalHours,
			SUM(CASE WHEN a.FiscalPeriod = @FiscalPeriod THEN a.ExtCost ELSE 0 END) AS MTDTotalCost,
			SUM(CASE WHEN a.FiscalPeriod = @FiscalPeriod THEN a.ExtIncome ELSE 0 END) AS MTDTotalAmt,
			SUM(CASE WHEN d.Billable = 1 THEN a.Qty ELSE 0 END) AS YTDBillableHours,
			SUM(CASE WHEN d.Billable = 1 THEN a.ExtCost ELSE 0 END) AS YTDBillableCost,
			SUM(CASE WHEN d.Billable = 1 THEN a.ExtIncome ELSE 0 END) AS YTDBillableAmt,
			SUM(CASE WHEN d.Billable = 0 THEN a.Qty ELSE 0 END) AS YTDNonBillableHours,
			SUM(CASE WHEN d.Billable = 0 THEN a.ExtCost ELSE 0 END) AS YTDNonBillableCost,
			SUM(CASE WHEN d.Speculative = 1 THEN a.Qty ELSE 0 END) AS YTDSpecHours,
			SUM(CASE WHEN d.Speculative = 1 THEN a.ExtCost ELSE 0 END) AS YTDSpecCost,
			SUM(CASE WHEN d.Speculative = 1 THEN a.ExtIncome ELSE 0 END) AS YTDSpecInc,
			SUM(CASE WHEN p.[Type] = 2 THEN a.Qty ELSE 0 END) AS YTDAdminHours,
			SUM(CASE WHEN p.[Type] = 2 THEN a.ExtCost ELSE 0 END) AS YTDAdminCost,		
			SUM(CASE WHEN p.[Type] = 1 THEN a.Qty ELSE 0 END) AS YTDJobCostHours,
			SUM(CASE WHEN p.[Type] = 1 THEN a.ExtCost ELSE 0 END) AS YTDJobCostCost,		
			SUM(ISNULL(a.Qty,0)) AS YTDTotalHours,
			SUM(ISNULL(a.ExtCost,0)) AS YTDTotalCost,
			SUM(ISNULL(a.ExtIncome,0)) AS YTDTotalAmt
		FROM #tmpEmployeeList t	INNER JOIN dbo.tblPcActivity a ON t.EmployeeId = a.ResourceId 
			INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		WHERE FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod AND a.[Type] = 0
		GROUP BY t.EmployeeId) s ON e.EmployeeId = s.EmployeeId

	SELECT EmpId, RateId, Rate, Cost,EarnCode, DefaultYN 
	FROM dbo.tblPcEmpRates 
	WHERE EmpId IN (SELECT EmployeeId FROM #tmpEmployeeList)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcEmployeeDetailList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcEmployeeDetailList_proc';


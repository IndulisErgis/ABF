
CREATE PROCEDURE dbo.trav_PcProjectSetupList_proc 
@IncludeTask bit
AS
BEGIN TRY
SET NOCOUNT ON

	--Project
	SELECT p.CustId, c.CustName, p.ProjectName, d.[Description] AS ProjDescription, 
		d.AddnlDesc, d.PhaseId, s.[Description] AS PhaseDescription, NULL AS TaskDescription, 
		d.TaskId, p.[Type], d.Billable, d.Speculative, d.BillOnHold, d.[Status], d.DistCode, 
		d.EstStartDate, d.ActStartDate, d.EstEndDate, d.ActEndDate, d.FixedFee, d.FixedFeeAmt, 
		d.RateId, d.OhAllCode, p.PrintOption, d.TaxClass, d.OverrideRate, d.MaterialMarkup, 
		d.ExpenseMarkup, d.OtherMarkup, d.ProjectManager, d.Rep1Id, d.Rep1Pct, d.Rep1CommRate,
		d.Rep2Id, d.Rep2Pct, d.Rep2CommRate,  ISNULL(f.FixedFeeAmtTotal,0) AS FixedFeeAmtTotal, si.Name, si.SiteID, si.Address1, si.Address2, si.Attention,
		si.City, si.Country, si.Email, si.Fax, si.PostalCode, si.Region
	FROM #tmpProjectList t INNER JOIN dbo.tblPcProject p ON t.ProjectId = p.Id 
		INNER JOIN dbo.tblPcProjectDetail d ON p.Id  = d.ProjectId
		LEFT JOIN dbo.tblPcProjectDetailSiteInfo si ON si.ProjectDetailID = d.Id
		LEFT JOIN dbo.tblPcPhase s ON d.PhaseId = s.PhaseId
		LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
		LEFT JOIN (SELECT p.Id, SUM(d.FixedFeeAmt) AS FixedFeeAmtTotal FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id  = d.ProjectId GROUP BY p.Id) f
			ON p.Id = f.Id
	WHERE d.TaskId IS NULL AND d.PhaseId IS NULL
	UNION ALL
	--Task
	SELECT p.CustId, c.CustName, p.ProjectName, h.[Description] AS ProjDescription, 
		d.AddnlDesc, d.PhaseId, s.[Description] AS PhaseDescription, d.[Description] AS TaskDescription, 
		d.TaskId, p.[Type], d.Billable, d.Speculative, d.BillOnHold, d.[Status], d.DistCode, 
		d.EstStartDate, d.ActStartDate, d.EstEndDate, d.ActEndDate, d.FixedFee, d.FixedFeeAmt, 
		d.RateId, d.OhAllCode, p.PrintOption, d.TaxClass, d.OverrideRate, d.MaterialMarkup, 
		d.ExpenseMarkup, d.OtherMarkup, d.ProjectManager, d.Rep1Id, d.Rep1Pct, d.Rep1CommRate,
		d.Rep2Id, d.Rep2Pct, d.Rep2CommRate, 0 AS FixedFeeAmtTotal, si.Name, si.SiteID, si.Address1, si.Address2, si.Attention,
		si.City, si.Country, si.Email, si.Fax, si.PostalCode, si.Region
	FROM #tmpProjectList t INNER JOIN dbo.tblPcProject p ON t.ProjectId = p.Id 
		INNER JOIN dbo.tblPcProjectDetail d ON p.Id  = d.ProjectId
		INNER JOIN dbo.tblPcProjectDetail h ON p.Id = h.ProjectId AND h.TaskId IS NULL AND h.PhaseId IS NULL
		LEFT JOIN dbo.tblPcProjectDetailSiteInfo si ON si.ProjectDetailID = h.Id
		LEFT JOIN dbo.tblPcPhase s ON d.PhaseId = s.PhaseId
		LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
	WHERE @IncludeTask = 1 AND d.TaskId IS NOT NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectSetupList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectSetupList_proc';


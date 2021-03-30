
CREATE PROCEDURE dbo.trav_ApTransPost_UpdateActivity_proc
AS
BEGIN TRY

	UPDATE dbo.tblPcActivity SET [Status] = 2, GLAcctCost = td.GLAcct, 
		ActivityDate = th.InvoiceDate, FiscalYear = th.FiscalYear, FiscalPeriod = th.GLPeriod
	FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
		INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
		INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
		INNER JOIN dbo.tblPcActivity ON p.ActivityId = dbo.tblPcActivity.Id 
	
	--Update actual start date
	UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
	FROM dbo.tblPcProjectDetail INNER JOIN 
		(SELECT p.ProjectDetailId, MIN(th.InvoiceDate) AS TransDate
		 FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum 
		 GROUP BY p.ProjectDetailId) t ON dbo.tblPcProjectDetail.Id = t.ProjectDetailId 
	WHERE dbo.tblPcProjectDetail.ActStartDate IS NULL
	
	UPDATE dbo.tblPcProjectDetail SET ActStartDate = t.TransDate
	FROM dbo.tblPcProjectDetail INNER JOIN 
		(SELECT d.ProjectId, MIN(th.InvoiceDate) AS TransDate
		 FROM #PostTransList l INNER JOIN dbo.tblApTransHeader th ON l.TransId = th.TransId
			INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
			INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
			INNER JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
			INNER JOIN dbo.tblPcProject j ON d.ProjectId = j.Id
		 GROUP BY d.ProjectId) t ON dbo.tblPcProjectDetail.ProjectId = t.ProjectId 
	WHERE dbo.tblPcProjectDetail.PhaseId IS NULL AND dbo.tblPcProjectDetail.TaskId IS NULL AND dbo.tblPcProjectDetail.ActStartDate IS NULL
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_UpdateActivity_proc';


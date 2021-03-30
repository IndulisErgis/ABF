
CREATE PROCEDURE dbo.trav_PcPrepareOverheadAllocation_proc
@PrecCurr tinyint,
@TransDate datetime
AS
BEGIN TRY

	DELETE dbo.tblPcPrepareOverhead

	--Project/task status is active;
	--Activity type is Time, Material, Expense or Other;
	--Activity source is Time Ticket, Transaction, Adjustment, AP Invoice, PO,
	-- PO Invoice,Bill Via is SD ,Bill Via is PC;
	--Activity status is Posted or higher status;
	INSERT INTO dbo.tblPcPrepareOverhead(ActivityId, OhAllCode, FiscalYear, FiscalPeriod, TransDate, CurrOH)
	SELECT a.Id, d.OhAllCode, a.FiscalYear, a.FiscalPeriod, @TransDate,
		CASE a.[Type] WHEN 0 THEN ROUND(o.[Hours] * a.Qty,@PrecCurr) + ROUND(o.[Time] * a.ExtCost,@PrecCurr)
		WHEN 1 THEN ROUND(o.Material * a.ExtCost,@PrecCurr) 
		WHEN 2 THEN ROUND(o.Expense * a.ExtCost,@PrecCurr)
		WHEN 3 THEN ROUND(o.Other * a.ExtCost,@PrecCurr) END - a.OverheadPosted AS CurrOH
	FROM #tmpActivityList t INNER JOIN dbo.tblPcActivity a ON t.Id = a.Id 
		INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id 
		INNER JOIN dbo.tblPcOhAlloc o ON d.OhAllCode = o.OhAllCode
	WHERE d.[Status] = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Source] IN (0,1,3,7,8,9,12,13,14) AND a.[Status] > 1

	DELETE dbo.tblPcPrepareOverhead 
	WHERE CurrOH = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareOverheadAllocation_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcPrepareOverheadAllocation_proc';


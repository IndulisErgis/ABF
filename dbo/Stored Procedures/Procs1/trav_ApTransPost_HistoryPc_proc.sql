
CREATE PROCEDURE dbo.trav_ApTransPost_HistoryPc_proc
AS
BEGIN TRY
DECLARE @PostRun nvarchar(14), @PrecUCost tinyint

--Retrieve global values
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @PrecUCost = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUnitCost'

IF @PostRun IS NULL OR @PrecUCost IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

-- append project detail info to tblApHistDetail
INSERT dbo.tblApHistDetail (PostRun, InvoiceNum, TransID, EntryNum, PartID, PartType, WhseId, [Desc], CostType, GLAcct
, Qty, QtyBase, Units, UnitsBase, UnitCost, UnitCostFgn, ExtCost, ExtCostFgn, GLDesc, AddnlDesc, HistSeqNum, TaxClass
, BinNum, ConversionFactor, LottedYN, InItemYN, GLAcctSales, TransHistId, ExtInc, GLAcctWIP
, CustomerID, JobId, ProjName, PhaseId, PhaseName, TaskId, TaskName,UnitInc,LineSeq,CF) 
SELECT @PostRun, th.InvoiceNum, td.TransID, td.EntryNum, PartID, PartType, td.WhseId, td.[Desc], CostType, td.GLAcct
, td.Qty, QtyBase, Units, UnitsBase, UnitCost, UnitCostFgn, td.ExtCost, ExtCostFgn, GLDesc, td.AddnlDesc, HistSeqNum, td.TaxClass
, BinNum, ConversionFactor, LottedYN, InItemYN, a.GLAcctIncome, p.ActivityId, ISNULL(a.ExtIncome,0), a.GLAcctWIP
, j.CustId, j.ProjectName, j.[Description], d.PhaseId, s.[Description], d.TaskId, 
CASE WHEN d.TaskId IS NULL THEN NULL ELSE d.[Description] END,
CASE WHEN td.Qty = 0 THEN 0 ELSE ROUND(ISNULL(a.ExtIncome,0)/td.Qty,@PrecUCost) END ,LineSeq,td.CF
FROM (dbo.tblApTransHeader th INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID) 
	INNER JOIN #PostTransList l ON th.TransId = l.TransId 
	INNER JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
	LEFT JOIN dbo.tblPcProjectDetail d ON p.ProjectDetailId = d.Id 
	LEFT JOIN dbo.trav_PcProject_view j ON d.ProjectId = j.Id
	LEFT JOIN dbo.tblPcPhase s ON d.PhaseId = s.PhaseId
	LEFT JOIN dbo.tblPcActivity a ON p.ActivityId = a.Id
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_HistoryPc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_HistoryPc_proc';


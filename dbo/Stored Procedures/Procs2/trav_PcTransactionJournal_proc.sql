
CREATE PROCEDURE dbo.trav_PcTransactionJournal_proc 
@PrecCurr smallint
AS
BEGIN TRY
SET NOCOUNT ON

	SELECT m.BatchId, m.Id AS TransId, m.TransDate, p.CustId, c.CustName AS CustomerName, p.ProjectName AS ProjectId, d.PhaseId, 
		d.TaskId, m.QtyFilled, m.QtyNeed, CASE m.TransType WHEN 1 THEN -1 ELSE 1 END * ROUND(m.QtyFilled * m.UnitCost,@PrecCurr) AS ExtCost, m.[Description], 
		m.[AddnlDesc], m.Markup, m.Uom, m.ItemId, m.LocId, m.FiscalYear, m.FiscalPeriod, 
		p.ProjectName + '/' + ISNULL(d.PhaseId,'') + '/' + ISNULL(d.TaskId,'') AS Project, m.TransType,
		CASE m.TransType WHEN 0 THEN ROUND(m.QtyFilled * m.UnitCost,@PrecCurr) ELSE 0 END AS RequisitionTotal,
		CASE m.TransType WHEN 1 THEN -ROUND(m.QtyFilled * m.UnitCost,@PrecCurr) ELSE 0 END AS ReturnTotal,
		CASE m.TransType WHEN 2 THEN ROUND(m.QtyFilled * m.UnitCost,@PrecCurr) ELSE 0 END AS ExpenseTotal,
		CASE m.TransType WHEN 3 THEN ROUND(m.QtyFilled * m.UnitCost,@PrecCurr) ELSE 0 END AS OtherTotal	
	FROM #tmpTransactionList t INNER JOIN dbo.tblPcTrans m ON t.Id = m.Id
		INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
	
	SELECT e.TransId, e.LotNum, e.QtyFilled, CASE h.TransType WHEN 1 THEN -1 ELSE 1 END * ROUND(e.QtyFilled * e.UnitCost,@PrecCurr) AS ExtCost
	FROM #tmpTransactionList t INNER JOIN dbo.tblPcTransExt e ON t.Id = e.TransId 
		INNER JOIN dbo.tblPcTrans h ON e.TransId = h.Id
	WHERE e.LotNum IS NOT NULL
	
	SELECT s.TransId, s.SerNum, s.LotNum, 1 AS QtyFilled, CASE h.TransType WHEN 1 THEN -1 ELSE 1 END * ROUND(s.UnitCost,@PrecCurr) AS ExtCost
	FROM #tmpTransactionList t INNER JOIN dbo.tblPcTransSer s ON t.Id = s.TransId 
		INNER JOIN dbo.tblPcTrans h ON s.TransId = h.Id
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransactionJournal_proc';


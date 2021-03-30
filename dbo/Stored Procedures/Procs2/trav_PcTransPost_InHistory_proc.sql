
CREATE PROCEDURE dbo.trav_PcTransPost_InHistory_proc
AS
BEGIN TRY

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT m.HistSeqNum, m.FiscalYear, m.FiscalPeriod, m.TransDate, m.BatchId
	FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
	WHERE m.HistSeqNum > 0 AND m.QtyFilled <> 0

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT d.HistSeqNum, m.FiscalYear, m.FiscalPeriod, m.TransDate, m.BatchId
	FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
		INNER JOIN dbo.tblPcTransExt d ON m.Id = d.TransId 
		INNER JOIN dbo.tblInItem i ON m.ItemId = i.ItemId 
	WHERE i.LottedYN = 1 AND d.LotNum IS NOT NULL AND d.QtyFilled <> 0 AND d.HistSeqNum > 0 --Lotted

	EXEC dbo.trav_InUpdateHistory_proc
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_InHistory_proc';


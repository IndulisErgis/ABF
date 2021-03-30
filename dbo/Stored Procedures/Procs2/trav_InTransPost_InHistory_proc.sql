
CREATE PROCEDURE dbo.trav_InTransPost_InHistory_proc
AS
BEGIN TRY

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT d.HistSeqNum, h.SumYear, h.GLPeriod, h.TransDate, h.BatchId
	FROM dbo.tblInTrans h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN dbo.tblInTransLot d ON h.TransId = d.TransId
	WHERE d.HistSeqNum > 0

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_InHistory_proc';


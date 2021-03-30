
CREATE PROCEDURE dbo.trav_WmTransPost_InHistory_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--identify the history entries to be updated as a result of the transactions being processed
	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT m.HistSeqNum, m.GlYear, m.GLPeriod, m.TransDate, m.BatchId
	FROM #PostTransList t INNER JOIN dbo.tblWmTrans m ON t.TransId = m.TransId
	WHERE m.HistSeqNum > 0


	EXEC dbo.trav_InUpdateHistory_proc

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_InHistory_proc';


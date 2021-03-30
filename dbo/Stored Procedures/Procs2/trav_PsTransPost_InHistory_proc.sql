
CREATE PROCEDURE dbo.trav_PsTransPost_InHistory_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @FiscalYear smallint, @FiscalPeriod smallint

	--Retrieve global values
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'

	IF @FiscalYear IS NULL OR @FiscalPeriod IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId)
	SELECT n.HistSeqNum, @FiscalYear, @FiscalPeriod, h.TransDate, NULL, t.InvoiceNum
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN tblPsTransDetail d ON h.ID = d.HeaderID
		INNER JOIN dbo.tblPsTransDetailIN n ON d.ID = n.DetailID

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_InHistory_proc';


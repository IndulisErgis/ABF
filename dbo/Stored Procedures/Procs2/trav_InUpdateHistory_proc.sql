
CREATE PROCEDURE dbo.trav_InUpdateHistory_proc
AS
SET NOCOUNT ON
BEGIN TRY
	--PET:http://webfront:801/view.php?id=242886

	UPDATE dbo.tblInHistDetail
		SET SumYear = t.FiscalYear, GLPeriod = t.FiscalPeriod,
			SumPeriod = t.FiscalPeriod, TransDate = t.TransDate,
			BatchId = t.BatchId, RefId = ISNULL(t.RefId, dbo.tblInHistDetail.RefId),
			PriceUnit = ISNULL(t.PriceUnit, dbo.tblInHistDetail.PriceUnit),
			PriceExt = ISNULL(t.PriceExt, dbo.tblInHistDetail.PriceExt)
	FROM dbo.tblInHistDetail INNER JOIN #InHistory t 
		ON dbo.tblInHistDetail.HistSeqNum = t.HistSeqNum 
		
	UPDATE dbo.tblInHistSer 
		SET InvcNum = t.RefId
	FROM dbo.tblInHistSer INNER JOIN dbo.tblInHistDetail d ON dbo.tblInHistSer.HistSeqNum = d.HistSeqNum 
		INNER JOIN #InHistory t ON d.HistSeqNum = t.HistSeqNum
	WHERE t.RefId IS NOT NULL --AR, SO
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdateHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdateHistory_proc';


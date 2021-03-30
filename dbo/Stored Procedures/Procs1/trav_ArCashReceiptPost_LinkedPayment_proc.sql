
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_LinkedPayment_proc
AS
BEGIN TRY

	--update linked payments from AR
	UPDATE dbo.tblArTransPmt SET PostedYn = 1 
	FROM #PostTransList
	WHERE dbo.tblArTransPmt.LinkId = #PostTransList.TransId

	--update linked payments from SO
	UPDATE dbo.tblSoTransPmt SET PostedYn = 1 
	FROM #PostTransList
	WHERE dbo.tblSoTransPmt.LinkId = #PostTransList.TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_LinkedPayment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_LinkedPayment_proc';


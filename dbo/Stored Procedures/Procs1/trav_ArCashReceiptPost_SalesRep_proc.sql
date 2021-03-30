--MOD:Deposit Invoices
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_SalesRep_proc
AS
BEGIN TRY
	DECLARE @UseCommissions bit

	--Retrieve global values
	SELECT @UseCommissions = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseCommissions'

	IF @UseCommissions IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--update Commissions (tblArCommInvc)
	IF (@UseCommissions = 1)
	BEGIN
		--update payment amounts for the commission 
		UPDATE dbo.tblArCommInvc 
			SET AmtPmt = AmtPmt + pmt.PmtAmt + pmt.[Difference]
		FROM dbo.tblArCommInvc
		INNER JOIN (SELECT h.CustId, d.InvcNum
			, Sum(d.PmtAmt) PmtAmt
			, Sum(d.[Difference]) [Difference]
			FROM dbo.tblArCashRcptHeader h 
			INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID
			INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
			GROUP BY h.CustId, d.InvcNum
		) pmt ON dbo.tblArCommInvc.CustId = pmt.CustId AND dbo.tblArCommInvc.InvcNum = pmt.InvcNum
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_SalesRep_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_SalesRep_proc';



CREATE PROCEDURE dbo.trav_BrTransPost_Master_proc
AS
BEGIN TRY

	DECLARE @CurrBase pCurrency

	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @CurrBase IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	/* append all non-voids to master (tblBrMaster) */
	INSERT dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, Amount, AmountFgn
	, CurrencyId, ExchRate, TransDate, FiscalYear, GlPeriod, SourceApp, ClearedYn, CF)
	SELECT h.BankID, TransType, SourceID, Descr, Reference, Amount * SIGN(TransType), AmountFgn * SIGN(TransType)
		, CurrencyId, ExchRate, TransDate, FiscalYear, GlPeriod, 'BR', 0, h.CF 
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
	WHERE h.VoidYn = 0

	/* append all voids (entered thru Transactions function) to master (tblBrMaster) */
	INSERT dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, Amount, AmountFgn
	, CurrencyId, ExchRate, TransDate, FiscalYear, GlPeriod, SourceApp, ClearedYn, VoidStop, CF)
	SELECT h.BankID, TransType, SourceID, Descr, Reference, Amount, AmountFgn
		, CurrencyId, ExchRate, TransDate, FiscalYear, GlPeriod, 'BR', 1, 1, h.CF 
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
	WHERE h.Amount = 0 AND h.VoidYn = 1 AND h.VoidReinstateStat IS NULL --MOD:Exclude externally voided payments

	/* append the "TO" side of transfers to master (tblBrMaster) */
	INSERT dbo.tblBrMaster (BankID, TransType, SourceID, Descr, Reference, Amount, AmountFgn
	, CurrencyId, ExchRate, TransDate, FiscalYear, GlPeriod, SourceApp, ClearedYn, VoidStop, CF)
	SELECT d.BankIDXferTo, h.TransType, h.SourceID, d.Descr, d.Reference, 
		CASE WHEN d.DebitAmt <> 0 THEN d.DebitAmt ELSE d.CreditAmt * -1 END
		, CASE WHEN b.CurrencyId = @CurrBase THEN CASE WHEN d.DebitAmt <> 0 THEN d.DebitAmt ELSE d.CreditAmt * -1 END 
			ELSE CASE WHEN d.DebitAmtFgn <> 0 THEN d.DebitAmtFgn ELSE d.CreditAmtFgn * -1 END END
		, b.CurrencyId, CASE WHEN b.CurrencyId = @CurrBase THEN 1 ELSE h.ExchRate END
		, h.TransDate, h.FiscalYear, h.GlPeriod, 'BR', 0, 0, d.CF 
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
		INNER JOIN dbo.tblBrJrnlDetail d ON h.TransID = d.TransID 
		INNER JOIN dbo.tblSmBankAcct b ON d.BankIDXferTo = b.BankId 
	WHERE h.TransType = -3

	/* all voids with a BR Source */
	UPDATE dbo.tblBrMaster SET VoidTransID = NULL, Amount = 0, AmountFgn = 0, ClearedYn = 1, VoidDate = h.TransDate
			, VoidPd = h.GlPeriod, VoidYear = h.FiscalYear, VoidAmt = h.Amount, VoidAmtFgn = h.AmountFgn   
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId
		INNER JOIN dbo.tblBrMaster m ON h.TransID = m.VoidTransID 
	WHERE h.VoidYn = 1 AND h.VoidReinstateStat IS NULL

	DELETE dbo.tblBrJrnlDetail
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader h ON t.TransId = h.BankId 
		INNER JOIN dbo.tblBrJrnlDetail ON h.TransId = dbo.tblBrJrnlDetail.TransId

	DELETE dbo.tblBrJrnlHeader 
	FROM #PostTransList t INNER JOIN dbo.tblBrJrnlHeader ON t.TransId = dbo.tblBrJrnlHeader.BankId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_Master_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrTransPost_Master_proc';


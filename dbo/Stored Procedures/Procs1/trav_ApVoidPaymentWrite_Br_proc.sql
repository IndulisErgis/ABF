--PET:http://problemtrackingsystem.osas.com/view.php?id=261264
CREATE PROCEDURE dbo.trav_ApVoidPaymentWrite_Br_proc
AS
BEGIN TRY

	UPDATE dbo.tblBrMaster SET VoidStop = 1, ClearedYn = 1, Amount = 0, AmountFgn = 0, VoidDate = t.VoidDate,
			VoidPd = t.VoidFiscalPeriod, VoidYear = t.VoidFiscalYear, VoidAmt = -t.SumGrossAmtDue - t.SumDiscAmt * -1
			, VoidAmtFgn = -t.SumGrossAmtDueFgn - t.SumDiscAmtFgn * -1, VoidTransID = NULL
	FROM dbo.tblBrMaster b 
	INNER JOIN (Select c.VoidBankId, NULLIF(c.CheckNum,'') CheckNum, c.CheckDate, c.VendorId,t.VoidFiscalYear,t.VoidFiscalPeriod,t.VoidDate
		, sum(c.GrossAmtDue) SumGrossAmtDue, sum(c.DiscAmt) SumDiscAmt
		, sum(Case When c.PmtCurrencyID <> c.CurrencyId Then c.GrossAmtDue Else c.GrossAmtDueFgn End) SumGrossAmtDueFgn
		, sum(Case When c.PmtCurrencyID <> c.CurrencyId Then c.DiscAmt Else c.DiscAmtFgn End) SumDiscAmtFgn
		From #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
		Group By c.VoidBankId, c.CheckNum, c.CheckDate, c.VendorId,t.VoidFiscalYear,t.VoidFiscalPeriod,t.VoidDate,t.[Status] having  t.[Status] = 0) t
		ON b.BankID = t.VoidBankId AND b.SourceID = t.CheckNum 
			AND b.TransDate = t.CheckDate AND b.Reference = t.VendorID 
	WHERE b.SourceApp = 'AP' OR b.SourceApp = 'PO' 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Br_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_Br_proc';


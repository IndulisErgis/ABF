
CREATE PROCEDURE dbo.trav_SoTransPost_OpenInvoice_proc
AS
SET NOCOUNT ON
BEGIN TRY
--PET:http://webfront:801/view.php?id=236845
--MOD:Finance Charge Enhancements
--MOD:Deposit Invoices - Exclude Proforma invoice

	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @MCYn bit

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @MCYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	--append invoices and credit memos 
	INSERT dbo.tblArOpenInvoice (CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, CredMemNum
		, CustPONum, SourceApp) 
	SELECT h.CustId, CASE WHEN TransType > 0 THEN 1 ELSE -1 END
		, CASE WHEN h.TransType < 0 
			THEN ISNULL(NULLIF(h.OrgInvcNum,''), b.DefaultInvoiceNumber) 
			ELSE b.DefaultInvoiceNumber
			END
		, InvcDate, DistCode, TermsCode, CurrencyID, ExchRate
		, TaxableSales + NonTaxableSales + SalesTax + TaxAmtAdj + Freight + Misc
		, TaxableSalesFgn + NonTaxableSalesFgn + SalesTaxFgn + TaxAmtAdjFgn + FreightFgn + MiscFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, @PostRun, h.TransId
		, CASE WHEN ISNULL(a.InvcNum, '') = '' THEN 0 ELSE 1 END
		, (CASE WHEN TransType < 0 THEN b.DefaultInvoiceNumber ELSE NULL END)
		, CustPONum, 1
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList b on h.TransId = b.TransId
	LEFT JOIN (SELECT CustId, InvcNum 
		FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND RecType<> 5 GROUP BY CustId, InvcNum) a 
		ON h.CustId = a.CustId AND h.OrgInvcNum = a.InvcNum 


	--append gain / loss records for credit memos, set gainlossstatus to 1, rectype -3 is used to indicate gain / loss
	INSERT dbo.tblArOpenInvoice 
		(CustId, RecType, InvcNum, TransDate, DistCode, TermsCode, CurrencyId, ExchRate, Amt, AmtFgn
		, DiscAmt, DiscAmtFgn, NetDueDate, DiscDueDate, GlPeriod, FiscalYear, PostRun, TransId, GainLossStatus, SourceApp) 
	SELECT h.CustId, -3, ISNULL(NULLIF(h.OrgInvcNum,''), b.DefaultInvoiceNumber)
		, InvcDate, DistCode, TermsCode, @CurrBase, 1, h.CalcGainLoss, 0, 0
		, 0, NetDueDate, NULL, GlPeriod, FiscalYear, @PostRun, h.TransId, 1
		, 1
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList b on h.TransId = b.TransId
	LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId 
	LEFT JOIN (SELECT CustId, InvcNum
		FROM dbo.tblArOpenInvoice WHERE RecType > 0 AND RecType<> 5  GROUP BY CustId, InvcNum) a 
		ON h.CustId = a.CustId AND h.OrgInvcNum = a.InvcNum 
	WHERE h.TransType < 0 AND h.CalcGainLoss <> 0

IF @MCYN = 1
	BEGIN
		--Gain/Loss for rounding
		--Get a list of invoices that have credit memo being posted.
		CREATE TABLE #OpenInvoice(CustId pCustId NOT NULL, InvcNum pInvoiceNum NOT NULL)
		
		INSERT INTO #OpenInvoice(CustId,InvcNum)
		SELECT h.CustId, h.OrgInvcNum
		FROM dbo.tblSoTransHeader h 
			INNER JOIN #PostTransList l ON h.TransId = l.TransId 
		WHERE h.TransType < 0 AND h.OrgInvcNum IS NOT NULL
		GROUP BY h.CustId, h.OrgInvcNum
		
		--Get a list of invoices that have gain/loss to be posted due to rounding.
		CREATE TABLE #GainLossInvoice(CustId pCustId NOT NULL, InvcNum pInvoiceNum NOT NULL,
			CreditCounter int NOT NULL, GainLossAmt Decimal(28,10) NOT NULL, GLAcctGainLoss pGlAcct NULL)
			
		INSERT INTO #GainLossInvoice(CustId,InvcNum,CreditCounter,GainLossAmt)
		SELECT h.CustId, h.InvcNum, MAX(CASE RecType WHEN -1 THEN i.[Counter] ELSE 0 END), SUM(SIGN(i.Rectype) * i.Amt)
		FROM #OpenInvoice h INNER JOIN dbo.tblArOpenInvoice i ON h.CustId = i.CustId AND h.InvcNum = i.InvcNum AND i.RecType<> 5 
		GROUP BY h.CustId,h.InvcNum
		HAVING SUM(SIGN(i.Rectype) * i.Amtfgn) = 0 AND SUM(SIGN(i.Rectype) * i.Amt) <> 0
		
		INSERT dbo.tblArOpenInvoice (CustId, InvcNum, Amt, AmtFgn, DiscAmt, DiscAmtFgn, RecType, PmtMethodId, CheckNum, CurrencyId, ExchRate, 
			TransDate, NetDueDate, DistCode, GlPeriod, FiscalYear, PostRun, TransID, GainLossStatus, SourceApp) 
		SELECT h.CustId, h.InvcNum, GainLossAmt, 0, 0, 0, -3, i.PmtMethodId, i.CheckNum, @CurrBase, 1
			, i.TransDate, i.NetDueDate, i.DistCode, i.GlPeriod, i.FiscalYear, @PostRun, i.TransId, 1, 1
		FROM #GainLossInvoice h INNER JOIN dbo.tblArOpenInvoice i ON h.CreditCounter = i.[Counter] AND i.RecType<> 5 
		
		UPDATE dbo.tblSoTransHeader SET CalcGainLoss = CalcGainLoss + g.GainLossAmt
		FROM dbo.tblSoTransHeader INNER JOIN dbo.tblArOpenInvoice i 
				ON dbo.tblSoTransHeader.CustId = i.CustId AND dbo.tblSoTransHeader.TransId = i.TransId AND i.RecType<> 5 
			INNER JOIN #GainLossInvoice g ON i.[Counter] = g.CreditCounter

	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_OpenInvoice_proc';


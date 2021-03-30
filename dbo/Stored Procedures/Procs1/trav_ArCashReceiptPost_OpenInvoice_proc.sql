
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_OpenInvoice_proc
AS
Set NoCount ON
BEGIN TRY

	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @CurrBase pCurrency, @MCYn bit, @PrecCurr smallint

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	
	IF @PostRun IS NULL OR @WrkStnDate IS NULL OR @CurrBase IS NULL OR @MCYn IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	  --append payments (cash receipts)
      INSERT dbo.tblArOpenInvoice 
            (CustId, InvcNum, Amt, AmtFgn, DiscAmt, DiscAmtFgn, RecType, PmtMethodId, CheckNum, CurrencyId, ExchRate
            , TransDate, NetDueDate, DistCode, GlPeriod, FiscalYear, PostRun, TransID, GainLossStatus, SourceApp) 
      SELECT h.CustId, d.InvcNum, d.PmtAmt + [Difference], d.PmtAmtFgn + DifferenceFgn, [Difference], DifferenceFgn, -2
            , PmtMethodId, CheckNum, CurrencyID, ExchRate, h.PmtDate, h.PmtDate, DistCode, GlPeriod, FiscalYear
            , @PostRun, h.RcptHeaderID, CASE WHEN ISNULL(a.InvcNum, '') = '' THEN 0 ELSE 1 END
            , ISNULL(a.SourceApp, CASE WHEN h.InvcAppId = 'SO' THEN 1 ELSE 0 END)
      FROM dbo.tblArCashRcptHeader h 
      INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
      INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
      LEFT JOIN (SELECT CustId, InvcNum, MIN(SourceApp) SourceApp, CASE RecType WHEN 5 THEN 5 ELSE 1 END RecType 
            FROM dbo.tblArOpenInvoice WHERE RecType > 0-- AND RecType <> 5
            GROUP BY CustId, InvcNum, CASE RecType WHEN 5 THEN 5 ELSE 1 END) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum AND d.InvcType = a.RecType
      WHERE h.CustId IS NOT NULL AND (d.InvcType <> 5 OR a.CustId IS NULL) --Cash receipt that is applied to a regular invoice OR cash receipt of deposit that is NOT applied to a pro forma invoice 

      --append Proforma Invoice record. Source - Proforma
      INSERT dbo.tblArOpenInvoice 
            (CustId, InvcNum,RecType,[Status],DistCode,TransDate,NetDueDate,
            Amt,AmtFgn,DiscAmt,DiscAmtFgn,
            CurrencyId,ExchRate,GlPeriod,FiscalYear,
            ProjId,PostRun,TransId,GainLossStatus,SourceApp,PmtMethodId,CheckNum) 
      SELECT h.CustId, d.InvcNum,5, 0,a.DistCode,h.PmtDate,h.PmtDate,
          -(ROUND((d.PmtAmtFgn + [DifferenceFgn])/a.ExchRate, @PrecCurr)), -(d.PmtAmtFgn + DifferenceFgn), (-ROUND([DifferenceFgn]/a.ExchRate, @PrecCurr)),(-DifferenceFgn), 
           a.CurrencyId,a.ExchRate,GlPeriod,FiscalYear,
           a.ProjId,@PostRun,h.RcptHeaderID,0,a.SourceApp,h.PmtMethodId,h.CheckNum         
      FROM dbo.tblArCashRcptHeader h 
      INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
      INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId   
      INNER JOIN (SELECT CustId, InvcNum, MIN(SourceApp) SourceApp, MIN(DistCode) DistCode, MIN(CurrencyId) CurrencyId, MIN(ExchRate) ExchRate, MIN(ProjId) ProjId 
            FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
            GROUP BY CustId, InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum 
      WHERE h.CustId IS NOT NULL --Cash receipt that is applied to a pro forma invoice    
      
      --append CR Deposit Invoice record. Source - Cash Receipt
      INSERT dbo.tblArOpenInvoice 
            (CustId, InvcNum,RecType,[Status],DistCode,TransDate,NetDueDate,
            Amt,AmtFgn,DiscAmt,DiscAmtFgn,
            CurrencyId,ExchRate,GlPeriod,FiscalYear,
            ProjId,PostRun,TransId,GainLossStatus,SourceApp,PmtMethodId,CheckNum) 
      SELECT h.CustId, a.ProjId,-2, 0,d.DistCode,h.PmtDate,h.PmtDate,
          d.PmtAmt + [Difference], d.PmtAmtFgn + DifferenceFgn, [Difference],DifferenceFgn, 
           h.CurrencyId,h.ExchRate,h.GlPeriod,h.FiscalYear,
           NULL,@PostRun,h.RcptHeaderID,0,a.SourceApp,h.PmtMethodId,h.CheckNum       
      FROM dbo.tblArCashRcptHeader h 
      INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
      INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId   
      INNER JOIN (SELECT CustId, InvcNum, MIN(SourceApp) SourceApp, MIN(DistCode) DistCode, MIN(CurrencyId) CurrencyId, MIN(ExchRate) ExchRate, MIN(ProjId) ProjId
            FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
           GROUP BY CustId, InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum 
      WHERE h.CustId IS NOT NULL--Cash receipt that is applied to a pro forma invoice       

	--append Gain / Loss records for payments - reverse sign since rectype is negative
	INSERT dbo.tblArOpenInvoice 
		(CustId, InvcNum, Amt, AmtFgn, DiscAmt, DiscAmtFgn, RecType, PmtMethodId, CheckNum, CurrencyId, ExchRate
		, TransDate, NetDueDate, DistCode, GlPeriod, FiscalYear, PostRun, TransID, GainLossStatus, SourceApp) 
	SELECT h.CustId, d.InvcNum, -CalcGainLoss, 0, 0, 0, -3, PmtMethodId, CheckNum, @CurrBase, 1
		, PmtDate, PmtDate, DistCode, GlPeriod, FiscalYear, @PostRun, h.RcptHeaderID, 1
		, ISNULL(a.SourceApp, CASE WHEN h.InvcAppId = 'SO' THEN 1 ELSE 0 END)
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	LEFT JOIN (SELECT CustId, InvcNum, MIN(SourceApp) SourceApp 
		FROM dbo.tblArOpenInvoice WHERE RecType > 0 
		GROUP BY CustId, InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum 
	WHERE d.CalcGainLoss <> 0 AND h.CustId IS NOT NULL


	--append CC Company Invoices
	INSERT dbo.tblArOpenInvoice 
		(CustId, PmtMethodId, Amt, AmtFgn, CurrencyId, ExchRate, TransDate, NetDueDate, RecType
		, DistCode, TermsCode, InvcNum, GlPeriod, FiscalYear, PostRun) 
	SELECT p.CustId, p.PmtMethodID
		, SUM(d.PmtAmt) PmtAmt
		, CASE WHEN c.CurrencyID = @CurrBase 
			THEN SUM(d.PmtAmt) 
			ELSE SUM(d.PmtAmtFgn) END PmtAmtFgn
		, c.CurrencyID
		, CASE WHEN c.CurrencyID = @CurrBase THEN 1 ELSE ExchRate END ExchRate
		, @WrkStnDate, @WrkStnDate, 1
		, c.DistCode, c.TermsCode, 'CC' + CONVERT(nvarchar(8), @WrkStnDate, 112) --PET:225704 - use the full date in the invoice number (CCYYYYMMDD)
		, h.GlPeriod, h.FiscalYear, @PostRun 
	FROM dbo.tblArPmtMethod p 
	INNER JOIN dbo.tblArCashRcptHeader h ON p.PmtMethodId = h.PmtMethodId
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	INNER JOIN dbo.tblArCust c ON p.CustId = c.CustId 
	WHERE (p.PmtType = 3 OR p.PmtType = 7) AND p.CustId IS NOT NULL AND ISNULL(p.BankId, '') = ''
	GROUP BY p.CustId, p.PmtMethodID, c.DistCode, c.TermsCode
		, c.CurrencyID, ExchRate, h.FiscalYear, h.GlPeriod
	HAVING SUM(d.PmtAmt) <> 0 AND SUM(d.PmtAmtFgn) <> 0 --skip net 0 invoices

	IF @MCYN = 1
	BEGIN
		--Gain/Loss for rounding
		BEGIN
			--Get a list of invoices that have payments being posted.
			CREATE TABLE #OpenInvoice(CustId pCustId NOT NULL, InvcNum pInvoiceNum NOT NULL)
			
			INSERT INTO #OpenInvoice(CustId,InvcNum)
			SELECT i.CustId, i.InvcNum
			FROM dbo.tblArCashRcptHeader h 
				INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
				INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
				INNER JOIN dbo.tblArOpenInvoice i ON h.CustId = i.CustId AND d.InvcNum = i.InvcNum	
			GROUP BY i.CustId, i.InvcNum

			--Get a list of invoices that have gain/loss to be posted due to rounding.
			CREATE TABLE #GainLossInvoice(CustId pCustId NOT NULL, InvcNum pInvoiceNum NOT NULL, CurrencyId pCurrency NOT NULL,
				PmtCounter int NOT NULL, GainLossAmt decimal(28,10) NOT NULL, GLAcctGainLoss pGlAcct NULL)
				
			INSERT INTO #GainLossInvoice(CustId,InvcNum,CurrencyId,PmtCounter,GainLossAmt)
			SELECT h.CustId, h.InvcNum, MAX(i.CurrencyId), MAX(CASE RecType WHEN -2 THEN i.[Counter] ELSE 0 END), SUM(SIGN(i.Rectype) * i.Amt)
			FROM #OpenInvoice h INNER JOIN dbo.tblArOpenInvoice i ON h.CustId = i.CustId AND h.InvcNum = i.InvcNum 
			GROUP BY h.CustId,h.InvcNum
			HAVING SUM(SIGN(i.Rectype) * i.Amtfgn) = 0 AND SUM(SIGN(i.Rectype) * i.Amt) <> 0
			
			UPDATE #GainLossInvoice SET GLAcctGainLoss = CASE WHEN GainLossAmt > 0 THEN ISNULL(g.GlAcctRealLoss, (SELECT GlAcctRealLoss FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) 
					ELSE ISNULL(g.GlAcctRealGain, (SELECT GlAcctRealGain FROM dbo.tblSmGainLossAccount WHERE CurrencyID = '~')) END
			FROM #GainLossInvoice LEFT JOIN dbo.tblSmGainLossAccount g ON #GainLossInvoice.CurrencyId = g.CurrencyID
			
			INSERT dbo.tblArOpenInvoice (CustId, InvcNum, Amt, AmtFgn, DiscAmt, DiscAmtFgn, RecType, PmtMethodId, CheckNum, CurrencyId, ExchRate, 
				TransDate, NetDueDate, DistCode, GlPeriod, FiscalYear, PostRun, TransID, GainLossStatus, SourceApp) 
			SELECT h.CustId, h.InvcNum, GainLossAmt, 0, 0, 0, -3, i.PmtMethodId, i.CheckNum, @CurrBase, 1
				, i.TransDate, i.NetDueDate, i.DistCode, i.GlPeriod, i.FiscalYear, @PostRun, i.TransId, 1, i.SourceApp
			FROM #GainLossInvoice h INNER JOIN dbo.tblArOpenInvoice i ON h.PmtCounter = i.[Counter]

			UPDATE dbo.tblArCashRcptDetail SET CalcGainLoss = CalcGainLoss - g.GainLossAmt,
				InvcExchRate = CASE WHEN (PmtAmt + [Difference] - (CalcGainLoss - g.GainLossAmt)) <> 0 
					THEN ROUND((PmtAmtFgn + [DifferenceFgn]) / (PmtAmt + [Difference] - (CalcGainLoss - g.GainLossAmt)), 10) 
					ELSE InvcExchRate 
					END,
				GLAcctGainLoss = CASE WHEN tblArCashRcptDetail.GLAcctGainLoss IS NULL THEN g.GLAcctGainLoss ELSE tblArCashRcptDetail.GLAcctGainLoss END
			FROM dbo.tblArCashRcptDetail INNER JOIN 
			(SELECT MAX(d.RcptDetailID) AS RcptDetailID, MAX(h.GainLossAmt) AS GainLossAmt, MAX(h.GLAcctGainLoss) AS GLAcctGainLoss
			FROM #GainLossInvoice h INNER JOIN dbo.tblArOpenInvoice i ON h.PmtCounter = i.[Counter]
				INNER JOIN dbo.tblArCashRcptDetail d ON i.TransId = d.RcptHeaderID AND i.InvcNum = d.InvcNum 
				INNER JOIN dbo.tblArCashRcptHeader c ON d.RcptHeaderID = c.RcptHeaderID AND i.CustId = c.CustId
	    	GROUP BY d.RcptHeaderID, d.InvcNum) g  ON tblArCashRcptDetail.RcptDetailID = g.RcptDetailID

		END
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_OpenInvoice_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_OpenInvoice_proc';


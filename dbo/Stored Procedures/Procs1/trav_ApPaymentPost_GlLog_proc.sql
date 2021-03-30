
CREATE PROCEDURE dbo.trav_ApPaymentPost_GlLog_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint,@Multicurr bit, @WksDate datetime,@CompId nvarchar(3),
	@DiscountDescr nvarchar(30), @CashDescr nvarchar(30), @PostGainLossDtl bit, @ApDetail bit, @CreditCardDescr nvarchar(30)

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @Multicurr = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @DiscountDescr = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'DiscountDescr'
	SELECT @CashDescr = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'CashDescr'
	SELECT @CreditCardDescr = Cast([Value] AS nvarchar(20)) FROM #GlobalValues WHERE [Key] = 'CreditCardDescr'
	SELECT @PostGainLossDtl = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostGainLossDtl'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @ApDetail = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApDetail'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @Multicurr IS NULL 
		OR @PostGainLossDtl IS NULL OR @CompId IS NULL OR @ApDetail IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	IF @Multicurr = 0
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT c.DistCode, 1, d.PayablesGLAcct, ROUND(SUM(GrossAmtDue), @PrecCurr), 0
			, 'AP', 'AP', 'AP', 0, 0, GlPeriod, FiscalYear, NULL, @CurrBase, 1, 0, 0, c.BatchID, c.CheckDate, c.CheckNum, -1
		FROM dbo.tblApPrepChkInvc c INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
		INNER JOIN dbo.tblApDistCode d ON c.DistCode = d.DistCode
		GROUP BY c.DistCode, d.PayablesGLAcct, GlPeriod, FiscalYear, c.BatchID, c.CheckDate, c.CheckNum
	END
	ELSE
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT c.DistCode, 0, d.PayablesGLAcct, BaseGrossAmtDue
			, CASE WHEN g.CurrencyId <> @CurrBase THEN GrossAmtDueFgn ELSE BaseGrossAmtDue END
			, SubString(c.InvoiceNum + ' / ' + c.BatchID,1,30), 'AP', c.VendorID, 0, 0, GlPeriod, FiscalYear, NULL
			, CASE WHEN g.CurrencyId <> @CurrBase THEN g.CurrencyId ELSE @CurrBase END
			, CASE WHEN  g.CurrencyId <> @CurrBase THEN c.ExchRate ELSE 1 END
			, 0	, 0, c.BatchID, c.CheckDate, c.CheckNum, -1
		FROM dbo.tblApPrepChkInvc c 
			INNER JOIN dbo.tblApDistCode d ON c.DistCode = d.DistCode 
			LEFT JOIN dbo.tblGlAcctHdr g ON d.PayablesGLAcct =  g.AcctId 
			INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
	END

	/* append discount entries */
	IF @Multicurr = 0  
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT DistCode, 2, GLDiscAcct, -ROUND(SUM(DiscTaken), @PrecCurr), 0, @DiscountDescr
			, 'AP', 'AP', 0, 0, GlPeriod, FiscalYear, NULL, @CurrBase,  1, 0, 0, i.BatchID, i.CheckDate, i.CheckNum, -1 
		FROM dbo.tblApPrepChkInvc i INNER JOIN #PostTransList b ON i.BatchId = b.TransId 
		GROUP BY DistCode, GLDiscAcct, GlPeriod, FiscalYear, i.BatchID, i.CheckDate, i.CheckNum
		HAVING ROUND(SUM(DiscTaken), @PrecCurr) <> 0 
	END
	ELSE
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT c.DistCode, 2, GLDiscAcct
			, -ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr)
			, -ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr)
			, SubString(c.InvoiceNum + ' / ' + c.BatchID,1,30), 'AP', c.VendorID, 0, 0, GlPeriod, FiscalYear, NULL, @CurrBase, 1
			, 0	, 0, c.BatchID, c.CheckDate, c.CheckNum, -1
		FROM dbo.tblApPrepChkInvc c INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
			INNER JOIN dbo.tblApDistCode d ON c.DistCode = d.DistCode 
			LEFT JOIN dbo.tblGlAcctHdr g ON d.PayablesGLAcct =  g.AcctId 
		WHERE ROUND(c.DiscTaken, @PrecCurr) <> 0
	END

	/* append cash entries - prepared checks */
	IF @Multicurr = 0  
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT DistCode, 3, i.GLCashAcct, ROUND(-SUM((GrossAmtDue) - DiscTaken), @PrecCurr), 0, CASE ISNULL(MIN(m.AcctType),0) WHEN 1 THEN @CreditCardDescr ELSE @CashDescr END
			, 'AP', 'AP', 0, 0, GlPeriod, FiscalYear, i.BankId, @CurrBase, 1, 0, 0, i.BatchID, i.CheckDate, i.CheckNum, -1
		FROM dbo.tblApPrepChkInvc i INNER JOIN #PostTransList b ON i.BatchId = b.TransId 
			LEFT JOIN dbo.tblSmBankAcct m ON i.BankID = m.BankId
		WHERE Status = 0
		GROUP BY DistCode, i.GLCashAcct, GlPeriod, FiscalYear, i.BankId, i.BatchID, i.CheckDate, i.CheckNum
	END
	ELSE
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT DistCode, 3, c.GLCashAcct
			, -ROUND((GrossAmtDueFgn - DiscTakenFgn)/ c.PmtExchRate, @PrecCurr) 
			, CASE WHEN g.CurrencyId <> @CurrBase THEN -(GrossAmtDueFgn - DiscTakenFgn)
				ELSE -ROUND((GrossAmtDueFgn - DiscTakenFgn)/ c.PmtExchRate, @PrecCurr) END
			, SubString(c.InvoiceNum + ' / ' + c.BatchID,1,30), 'AP', c.VendorID, 0, 0, GlPeriod, FiscalYear, c.BankId
			, CASE WHEN g.CurrencyId <> @CurrBase THEN g.CurrencyId ELSE @CurrBase END
			, CASE WHEN g.CurrencyId <> @CurrBase THEN PmtExchRate ELSE 1 END
			, 0	, 0, c.BatchID, c.CheckDate, c.CheckNum, -1
		FROM dbo.tblApPrepChkInvc c INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
		LEFT JOIN dbo.tblGlAcctHdr g ON c.GLCashAcct =  g.AcctId 
		LEFT JOIN dbo.tblSmBankAcct m ON c.BankID = m.BankId
		WHERE c.Status = 0 AND (c.CurrencyId <> @CurrBase OR (c.CurrencyId = @CurrBase AND c.PmtCurrencyId = @CurrBase ))--Foreign invoice or base currecy invoice paid with base currency 
		UNION ALL
		SELECT DistCode, 3, c.GLCashAcct
			, -(GrossAmtDue - DiscTaken)
			,  ROUND(-(GrossAmtDue - DiscTaken) * c.PmtExchRate, ISNULL(t.CurrDecPlaces,@PrecCurr) )
			, SubString(c.InvoiceNum + ' / ' + c.BatchID,1,30), 'AP', c.VendorID, 0, 0, GlPeriod, FiscalYear, c.BankId
			, c.PmtCurrencyId
			, c.PmtExchRate
			, 0	, 0, c.BatchID, c.CheckDate, c.CheckNum, -1
		FROM dbo.tblApPrepChkInvc c INNER JOIN #PostTransList b ON c.BatchId = b.TransId 
			LEFT JOIN dbo.tblGlAcctHdr g ON c.GLCashAcct =  g.AcctId 
			LEFT JOIN #tmpCurrencyList t ON c.PmtCurrencyId = t.CurrencyId 
			LEFT JOIN dbo.tblSmBankAcct m ON c.BankID = m.BankId
		WHERE c.Status = 0 AND (c.CurrencyId = @CurrBase AND c.PmtCurrencyId <> @CurrBase ) --base currecy invoice paid with foreign currency
	END

	/* append cash entries - prepaid checks */
	IF @Multicurr = 0  
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT DistCode, 4, i.GLCashAcct, ROUND(-SUM(GrossAmtDue - DiscTaken), @PrecCurr), 0, CASE ISNULL(MIN(m.AcctType),0) WHEN 1 THEN @CreditCardDescr ELSE @CashDescr END
			, 'AP', 'AP', 0, 0, GlPeriod, FiscalYear, i.BankId, @CurrBase, 1, 0,0, i.BatchID, i.CheckDate, i.CheckNum, -1
		FROM dbo.tblApPrepChkInvc i INNER JOIN #PostTransList b ON i.BatchId = b.TransId 
			LEFT JOIN dbo.tblSmBankAcct m ON i.BankID = m.BankId
		WHERE Status = 3
		GROUP BY DistCode, i.GLCashAcct, GlPeriod, FiscalYear, i.BankId, i.BatchID, i.CheckDate, i.CheckNum
	END
	ELSE
	BEGIN
		INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
		SELECT DistCode, 4, c.GLCashAcct, ROUND(-((GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate), @PrecCurr)
			, CASE WHEN g.CurrencyId <> @CurrBase THEN -(GrossAmtDueFgn - DiscTakenFgn)
				ELSE ROUND(-(GrossAmtDueFgn-DiscTakenfgn) / c.PmtExchRate, @PrecCurr) END
			, SubString(c.InvoiceNum + ' / ' + c.BatchID,1,30), 'AP', c.VendorID, 0, 0, GlPeriod, FiscalYear, c.BankId
			, CASE WHEN g.CurrencyId <> @CurrBase THEN g.CurrencyId ELSE @CurrBase END
			, CASE WHEN g.CurrencyId <> @CurrBase THEN PmtExchRate ELSE 1  END
			, 0	, 0, c.BatchID, c.CheckDate, c.CheckNum, -1 
		FROM dbo.tblApPrepChkInvc c INNER JOIN #PostTransList b ON  c.BatchId = b.TransId 
		LEFT JOIN dbo.tblGlAcctHdr g ON c.GLCashAcct =  g.AcctId 
		LEFT JOIN dbo.tblSmBankAcct m ON c.BankID = m.BankId
		WHERE c.Status = 3
	END

	/* append cash entries - prepaid check Gain Loss entries */

	IF @Multicurr = 1
	BEGIN
		IF @PostGainLossDtl = 1
		BEGIN
			INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
			SELECT i.DistCode, 5
				, CASE WHEN ((SUM(((i.GrossAmtDueFgn-i.DiscTakenFgn) / i.PmtExchRate)) - SUM(i.BaseGrossAmtDue-i.DiscTaken)) < 0)
					THEN g.RealGainAcct 
					ELSE g.RealLossAcct 
				END 
				, SUM((ROUND((i.GrossAmtDueFgn - i.DiscTakenFgn) / i.PmtExchRate, @PrecCurr)) - ((i.BaseGrossAmtDue) 
					- ROUND((i.DiscTakenFgn / i.ExchRate), @PrecCurr)))
				, SUM((ROUND((i.GrossAmtDueFgn - i.DiscTakenFgn) / i.PmtExchRate, @PrecCurr)) - ((i.BaseGrossAmtDue) 
					- ROUND((i.DiscTakenFgn / i.ExchRate), @PrecCurr)))
				, 'Gains/Losses', 'G0', 'AP Gain/Loss', 0, 0, i.GlPeriod, i.FiscalYear, BankId
				, @CurrBase, 1  AS ExchRate	, 0	, 0, i.BatchID, i.CheckDate, i.CheckNum, -6
			FROM dbo.tblApPrepChkInvc i 
				INNER JOIN dbo.tblApPrepChkCheck C ON i.BatchID = c.BatchID AND i.VendorId = C.VendorId AND i.GrpID = C.GrpID 
				INNER JOIN #PostTransList b ON  i.BatchId = b.TransId 
				INNER JOIN #GainLossAccounts g ON i.CurrencyId = g.CurrencyId 
				Left Join dbo.tblApDistCode dc on i.DistCode = dc.DistCode 
				Left Join dbo.tblGlAcctHdr h on h.AcctId = dc.PayablesGLAcct 
			WHERE i.CurrencyID <> @CurrBase AND i.Status = 0
			GROUP BY  i.vendorId, i.status,  i.DistCode, i.CurrencyId, i.PmtCurrencyId
				, i.GlPeriod, i.FiscalYear, i.BankId, i.GrpID, i.BatchID, i.CheckDate
				, g.RealGainAcct, g.RealLossAcct, g.CurrencyId, i.CheckNum
			UNION ALL

			SELECT i.DistCode, 5, i.GLAccGainLoss, ROUND(i.CalcGainLoss, @PrecCurr), ROUND(i.CalcGainLoss, @PrecCurr)
				, 'Gains/Losses', 'G0', 'AP Gain/Loss', 0, 0, i.GlPeriod, i.FiscalYear, i.BankId, @CurrBase
				, 1 AS ExchRate, ROUND(i.CalcGainLoss, @PrecCurr), ROUND(i.CalcGainLoss, @PrecCurr), i.BatchID, i.CheckDate, i.CheckNum, -6
			FROM dbo.tblApPrepChkInvc i INNER JOIN #PostTransList b ON b.TransId  =  i.BatchID  
			WHERE i.CurrencyID <> @CurrBase AND i.Status = 3 AND i.CalcGainLoss <> 0
		END
 		ELSE
		BEGIN
			INSERT INTO #ApPaymentPostLog(DistCode, [Order], GlAcct, Amount, AmountFgn, [Desc], SourceCode, Reference, DebitAmt, CreditAmt, GlPeriod, 
			FiscalYear, BankId, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, BatchID, CheckDate,LinkID,LinkIDSubLine)
			SELECT DistCode, [Order], GlAcct, SUM(Amount), SUM(Amountfgn), [Desc], SourceCode
				, Reference,  DebitAmt, CreditAmt, GlPeriod, FiscalYear, BankId,CurrencyId, MAX(ExchRate), 0, 0, GnLos.BatchID, CheckDate, CheckNum, -6

			FROM (

				SELECT i.DistCode, 5 AS [Order]
				, CASE WHEN ((SUM((i.GrossAmtDueFgn-i.DiscTakenfgn) / i.PmtExchRate) - SUM((i.GrossAmtDuefgn-i.DiscTakenfgn) / i.ExchRate)) < 0) --PTS 45583 (2)
					THEN g.RealGainAcct 
					ELSE g.RealLossAcct 
				END GlAcct
				, SUM((ROUND((i.GrossAmtDueFgn - i.DiscTakenFgn) / i.PmtExchRate, @PrecCurr)) - ((i.BaseGrossAmtDue) 
					- ROUND((i.DiscTakenFgn / i.ExchRate), @PrecCurr))) AS Amount
				, SUM((ROUND((i.GrossAmtDueFgn - i.DiscTakenFgn) / i.PmtExchRate, @PrecCurr)) - ((i.BaseGrossAmtDue) 
					- ROUND((i.DiscTakenFgn / i.ExchRate), @PrecCurr))) AS AmountFgn
				, 'Gains/Losses Sum' AS [Desc], 'G0' AS SourceCode, 'AP Gain/Loss' AS Reference, 0 AS DebitAmt, 0 AS CreditAmt, i.GlPeriod AS GlPeriod, i.FiscalYear AS FiscalYear
				,  '' AS BankId, @CurrBase AS CurrencyId, 1  AS ExchRate
				, i.BatchID, i.CheckDate, i.CheckNum
			FROM dbo.tblApPrepChkInvc i 
				INNER JOIN dbo.tblApPrepChkCheck C ON i.BatchID = c.BatchID AND i.VendorId = C.VendorId AND i.GrpID = C.GrpID 
				INNER JOIN #PostTransList b ON  i.BatchId = b.TransId 
				INNER JOIN #GainLossAccounts g ON i.CurrencyId = g.CurrencyId 
				Left Join dbo.tblApDistCode dc on i.DistCode = dc.DistCode 
				Left Join dbo.tblGlAcctHdr h on h.AcctId = dc.PayablesGLAcct 
			WHERE i.CurrencyID <> @CurrBase AND i.Status = 0 
			GROUP BY  i.status, i.DistCode, i.CurrencyId, i.PmtCurrencyId, i.GlPeriod, i.FiscalYear, i.BatchID, i.CheckDate
				, g.RealGainAcct, g.RealLossAcct, h.CurrencyId, i.CheckNum 
			UNION

			SELECT i.DistCode,  5 AS [Order],  i.GLAccGainLoss AS GlAcct, ROUND(SUM(i.CalcGainLoss), @PrecCurr) AS Amount
				, ROUND(SUM(i.CalcGainLoss), @PrecCurr) AS AmountFgn, 'Gains/Losses Sum' AS [Desc]
				, 'G0', 'AP Gain/Loss', 0 AS DebitAmt, 0 AS CreditAmt
				, i.GlPeriod AS GlPeriod, i.FiscalYear AS FiscalYear, '' AS BankId, @CurrBase AS CurrencyId, 1  AS ExchRate
				, i.BatchID, i.CheckDate, i.CheckNum

			FROM dbo.tblApPrepChkInvc i 
			INNER JOIN #PostTransList b ON  i.BatchId = b.TransId 
			WHERE i.CurrencyID <> @CurrBase AND i.Status = 3 AND i.CalcGainLoss <> 0
					GROUP BY  i.status,  i.DistCode, i.GLAccGainLoss, i.GlPeriod, i.FiscalYear, i.BatchID, i.CheckDate, i.CheckNum ) GnLos 
			GROUP BY DistCode, [Order], GlAcct, [Desc],SourceCode, Reference
				, DebitAmt, CreditAmt, GlPeriod, FiscalYear, CurrencyId, BankId, GnLos.BatchID, CheckDate, CheckNum

		END
	END

	/* split DRs & CRs */
	UPDATE #ApPaymentPostLog SET DebitAmt = CASE WHEN Amount > 0 THEN Amount ELSE 0 END
		, CreditAmt = CASE WHEN Amount < 0 THEN -Amount ELSE 0 END
		, DebitAmtfgn = CASE WHEN CurrencyId <> @CurrBase THEN 	(CASE WHEN Amountfgn > 0 THEN Amountfgn ELSE 0 END) 
			ELSE (CASE WHEN Amount > 0 THEN Amount ELSE 0 END) END
		, CreditAmtfgn = CASE WHEN CurrencyId <> @CurrBase THEN (CASE WHEN Amountfgn < 0 THEN -Amountfgn ELSE 0 END) 
			ELSE (CASE WHEN Amount < 0 THEN -Amount ELSE 0 END) END 

	IF @ApDetail = 1
	BEGIN
		IF @Multicurr = 0 
			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BankId,BatchId,LinkID,LinkIDSubLine)
			SELECT @PostRun, FiscalYear, GlPeriod, CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, 
				GlAcct, SUM(AmountFgn), Reference, [Desc], SUM(DebitAmt), SUM(CreditAmt),
				SUM(DebitAmtfgn), SUM(CreditAmtfgn), SourceCode, @WksDate, CheckDate, @CurrBase, 1, @CompId, DistCode, BankId, BatchId, LinkID, LinkIDSubLine
			FROM #ApPaymentPostLog
			GROUP BY CheckDate, [Desc], SourceCode, Reference, GlAcct, GlPeriod, FiscalYear, DistCode, BankId, BatchId, LinkID, LinkIDSubLine 
				, CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END -- group prepared and prepaid checks together 
			HAVING SUM(DebitAmt) <> 0 OR SUM(CreditAmt) <> 0
		ELSE
			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BankId,BatchId,LinkID,LinkIDSubLine)
			SELECT @PostRun, FiscalYear, GlPeriod, CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, 
				GlAcct, AmountFgn, Reference, [Desc], DebitAmt, CreditAmt,
				DebitAmtfgn, CreditAmtfgn, SourceCode, @WksDate, CheckDate, CurrencyId, ExchRate, @CompId, DistCode, BankId, BatchId, LinkID, LinkIDSubLine 
			FROM #ApPaymentPostLog
			WHERE (DebitAmt <> 0 OR CreditAmt <> 0)
	END
	ELSE
	BEGIN
			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkIDSubLine)
			SELECT @PostRun, FiscalYear, GlPeriod, CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, 
				GlAcct, SUM(AmountFgn), 'AP', 
				CASE [Order] WHEN 0 THEN 'AP' WHEN 1 THEN 'AP' WHEN 2 THEN @DiscountDescr WHEN 3 THEN @CashDescr WHEN 4 THEN @CashDescr ELSE NULL END,
				SUM(DebitAmt), SUM(CreditAmt),	SUM(DebitAmtfgn), SUM(CreditAmtfgn), 'AP', @WksDate, @WksDate, @CurrBase, 1, @CompId, -1
			FROM #ApPaymentPostLog
			WHERE DebitAmt <> 0
			GROUP BY GlAcct, GlPeriod, FiscalYear,
				CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, -- group prepared and prepaid checks together 
				CASE [Order] WHEN 0 THEN 'AP' WHEN 1 THEN 'AP' WHEN 2 THEN @DiscountDescr WHEN 3 THEN @CashDescr WHEN 4 THEN @CashDescr ELSE NULL END

			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkIDSubLine)
			SELECT @PostRun, FiscalYear, GlPeriod, CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, 
				GlAcct, SUM(AmountFgn), 'AP', 
				CASE [Order] WHEN 0 THEN 'AP' WHEN 1 THEN 'AP' WHEN 2 THEN @DiscountDescr WHEN 3 THEN @CashDescr WHEN 4 THEN @CashDescr ELSE NULL END,
				SUM(DebitAmt), SUM(CreditAmt),	SUM(DebitAmtfgn), SUM(CreditAmtfgn), 'AP', @WksDate, @WksDate, @CurrBase, 1, @CompId, -1
			FROM #ApPaymentPostLog
			WHERE CreditAmt <> 0
			GROUP BY GlAcct, GlPeriod, FiscalYear,
				CASE [Order] WHEN 0 THEN 0 WHEN 1 THEN 1 WHEN 2 THEN 2 WHEN 5 THEN 5 ELSE 9 END, -- group prepared and prepaid checks together 
				CASE [Order] WHEN 0 THEN 'AP' WHEN 1 THEN 'AP' WHEN 2 THEN @DiscountDescr WHEN 3 THEN @CashDescr WHEN 4 THEN @CashDescr ELSE NULL END

	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApPaymentPost_GlLog_proc';


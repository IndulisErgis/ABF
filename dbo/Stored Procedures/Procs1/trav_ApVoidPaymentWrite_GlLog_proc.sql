
CREATE PROCEDURE dbo.trav_ApVoidPaymentWrite_GlLog_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint,@Multicurr bit, @WksDate datetime,@CompId nvarchar(3),
	@DiscountDescr nvarchar(30), @CashDescr nvarchar(30),@PostGainLossDtl bit, @ApDetail bit, @CreditCardDescr nvarchar(30), 
	@ApBrYn bit

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
	SELECT @ApBrYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApBrYn'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @Multicurr IS NULL 
		OR @PostGainLossDtl IS NULL OR @CompId IS NULL OR @ApDetail IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END		

	IF (@ApBrYn <> 0)
	BEGIN
		UPDATE #PostTransList SET [Status] = -1
			WHERE #PostTransList.GrossAmountDue <> 0
			AND NOT EXISTS (
				SELECT 1 FROM dbo.tblBrMaster m
				WHERE  (m.SourceApp = 'AP' OR SourceApp = 'PO') 
					AND m.TransType = -1
					AND m.ClearedYn = 0
					AND m.BankID = #PostTransList.VoidBankId
					AND m.TransDate = #PostTransList.CheckDate
					AND ((m.SourceID = #PostTransList.UseCheckNumber AND m.Reference = #PostTransList.VendorId) --full match on check number and employee id
					
						) 
					)
	END

	CREATE TABLE #VoidGlPostLogs([PostRun] pPostRun NOT NULL,[CompId] nvarchar(3) NOT NULL,[GlAccount] pGlAcct NULL,
		[FiscalYear] smallint NOT NULL,[FiscalPeriod] smallint NOT NULL,[Description] nvarchar(30) NULL,
		[Reference] nvarchar(15) NULL,[SourceCode] nvarchar(2) NULL,[AmountFgn] pDecimal NOT NULL,[CreditAmount] pDecimal NOT NULL,
		[DebitAmount] pDecimal NOT NULL,[CurrencyId] pCurrency NOT NULL,[ExchRate] pDecimal NOT NULL,[CreditAmountFgn] pDecimal NOT NULL,
		[DebitAmountFgn] pDecimal NOT NULL,[Grouping] int NULL,[TransDate] datetime NULL,[PostDate] datetime NULL,
		[LinkId] nvarchar(15) NULL,[LinkIdSub] nvarchar(15) NULL,[LinkIdSubLine] int NULL,[DistCode] pDistCode NULL,[BankId] pBankId NULL)

	IF @Multicurr = 0
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
				TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,10,c.GLAcctAP,SUM(c.GrossAmtDue),'AP',
			MIN(t.VoidDate),@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP'
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
		GROUP BY c.VoidBankId, c.DistCode, c.GLAcctAP,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum,t.[Status]
		HAVING t.[Status] = 0
	END
	ELSE
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
				TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference, PostDate)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,10,c.GLAcctAP,
			CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN c.GrossAmtDueFgn
				ELSE c.BaseGrossAmtDue END,
			'AP',t.VoidDate, ISNULL(g.CurrencyId,@CurrBase), 
			CASE WHEN  ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN c.ExchRate ELSE 1 END,
			@CompId,c.VoidBankId, c.DistCode,
			CASE WHEN c.GrossAmtDueFgn < 0 THEN ABS(c.BaseGrossAmtDue) ELSE 0 END AS DebitAmount,
		    CASE WHEN c.GrossAmtDueFgn > 0 THEN c.BaseGrossAmtDue ELSE 0 END AS CreditAmount,
		    CASE WHEN c.GrossAmtDueFgn < 0 THEN -CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN c.GrossAmtDueFgn
				ELSE c.BaseGrossAmtDue END ELSE 0 END AS DebitAmountFgn,
		    CASE WHEN c.GrossAmtDueFgn > 0 THEN CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN c.GrossAmtDueFgn
				ELSE c.BaseGrossAmtDue	END ELSE 0 END AS CreditAmountFgn, 
			c.CheckNum,-2,'AP','AP', @WksDate
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
			LEFT JOIN dbo.tblGlAcctHdr g ON c.GLAcctAP =  g.AcctId 
		WHERE (c.CurrencyId <> @CurrBase OR (c.CurrencyId = @CurrBase AND c.PmtCurrencyId = @CurrBase ))--Foreign invoice or base currecy invoice paid with base currency
		AND  t.[Status] = 0
		UNION ALL
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,10,c.GLAcctAP,
			c.GrossAmtDue, 'AP',t.VoidDate, @CurrBase, 1,
			@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP', @WksDate
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
			LEFT JOIN dbo.tblGlAcctHdr g ON c.GLAcctAP =  g.AcctId 
		WHERE (c.CurrencyId = @CurrBase AND c.PmtCurrencyId <> @CurrBase ) AND t.[Status] = 0 --base currecy invoice paid with foreign currency
	END

	/* append discount entries */
	IF @Multicurr = 0
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
			TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,20,c.GLDiscAcct,SUM(DiscTaken) * -1,@DiscountDescr,
			MIN(t.VoidDate),@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP'
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
		GROUP BY c.VoidBankId, c.DistCode, c.GLDiscAcct,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum, t.[Status]
		HAVING SUM(DiscTaken) <> 0 AND t.[Status] = 0
	END
	ELSE
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
			TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,20,c.GLDiscAcct,
			CASE WHEN c.CurrencyID <> @CurrBase AND c.ExchRate <> ISNULL(c.PmtExchRate, 1)
				THEN - ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr) 
				ELSE - ROUND((c.DiscTakenFgn / c.PmtExchRate), @PrecCurr) END,
			@DiscountDescr,t.VoidDate,@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP'
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
		WHERE ROUND(DiscTaken, @PrecCurr) <> 0 AND (c.CurrencyId <> @CurrBase OR (c.CurrencyId = @CurrBase AND c.PmtCurrencyId = @CurrBase )) AND t.[Status] = 0--Foreign invoice or base currecy invoice paid with base currency 
		UNION ALL
			SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,20,c.GLDiscAcct,
			-c.DiscTaken, @DiscountDescr,t.VoidDate,@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP'
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
		WHERE ROUND(DiscTaken, @PrecCurr) <> 0 AND (c.CurrencyId = @CurrBase AND c.PmtCurrencyId <> @CurrBase ) AND t.[Status] = 0 --base currecy invoice paid with foreign currency
	END

	/* append cash entries */
	IF @Multicurr = 0
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
			TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,30,c.GlCashAcct,SUM(GrossAmtDue - DiscTaken) * -1,CASE ISNULL(MIN(b.AcctType),0) WHEN 1 THEN @CreditCardDescr ELSE @CashDescr END,
			MIN(t.VoidDate),@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP'
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
			LEFT JOIN dbo.tblSmBankAcct b ON c.VoidBankId = b.BankId
		GROUP BY c.VoidBankId, c.DistCode, c.GlCashAcct,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum,t.[Status] 
		HAVING t.[Status] = 0
	END
	ELSE
	BEGIN
		INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
			TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference, PostDate)
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,30,c.GlCashAcct,
			CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN (c.GrossAmtDueFgn - c.DiscTakenFgn) * -1
					ELSE - ROUND((c.GrossAmtDueFgn - c.DiscTakenFgn) / c.PmtExchRate, @PrecCurr) END,
			CASE ISNULL(b.AcctType,0) WHEN 1 THEN @CreditCardDescr ELSE @CashDescr END,t.VoidDate,ISNULL(g.CurrencyId,@CurrBase),
			CASE WHEN ISNULL(g.CurrencyId,@CurrBase) <> @CurrBase THEN c.PmtExchRate ELSE 1 END,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-2,'AP','AP',@WksDate
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
			LEFT JOIN dbo.tblGlAcctHdr g ON c.GlCashAcct =  g.AcctId 
			LEFT JOIN dbo.tblSmBankAcct b ON c.VoidBankId = b.BankId
		WHERE (c.CurrencyId <> @CurrBase OR (c.CurrencyId = @CurrBase AND c.PmtCurrencyId = @CurrBase )) AND t.[Status] = 0--Foreign invoice or base currecy invoice paid with base currency 
		UNION ALL
		SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,30,c.GlCashAcct,
			ROUND((c.GrossAmtDue - c.DiscTaken) * -1 * c.PmtExchRate, ISNULL(l.CurrDecPlaces,@PrecCurr) ),
			CASE ISNULL(b.AcctType,0) WHEN 1 THEN @CreditCardDescr ELSE @CashDescr END,t.VoidDate,ISNULL(g.CurrencyId,@CurrBase),
			c.PmtExchRate,@CompId,c.VoidBankId, c.DistCode,
			CASE WHEN (c.GrossAmtDue - c.DiscTaken) * -1 < 0 THEN c.GrossAmtDue - c.DiscTaken ELSE 0 END,
			CASE WHEN (c.GrossAmtDue - c.DiscTaken) * -1 > 0 THEN (c.GrossAmtDue - c.DiscTaken) * -1 ELSE 0 END,
			CASE WHEN (c.GrossAmtDue - c.DiscTaken) * -1 * c.PmtExchRate < 0 THEN ROUND((c.GrossAmtDue - c.DiscTaken) * c.PmtExchRate, ISNULL(l.CurrDecPlaces,@PrecCurr) ) ELSE 0 END,
			CASE WHEN (c.GrossAmtDue - c.DiscTaken) * -1 * c.PmtExchRate > 0 THEN ROUND((c.GrossAmtDue - c.DiscTaken) * -1 * c.PmtExchRate, ISNULL(l.CurrDecPlaces,@PrecCurr) ) ELSE 0 END,
			c.CheckNum,-2,'AP','AP',@WksDate
		FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter 
			LEFT JOIN dbo.tblGlAcctHdr g ON c.GlCashAcct =  g.AcctId 
			LEFT JOIN #tmpCurrencyList l ON c.PmtCurrencyId = l.CurrencyId
			LEFT JOIN dbo.tblSmBankAcct b ON c.VoidBankId = b.BankId
		WHERE (c.CurrencyId = @CurrBase AND c.PmtCurrencyId <> @CurrBase ) AND t.[Status] = 0 --base currecy invoice paid with foreign currency
	END

	IF @Multicurr = 1
	BEGIN
		IF @PostGainLossDtl = 1
		BEGIN
			INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
				TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
			SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,40,c.GLAcctGainLoss,
					SUM((ROUND((c.GrossAmtDueFgn - c.DiscTakenFgn) / c.PmtExchRate, @PrecCurr)) 
						- ((c.BaseGrossAmtDue) - ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr))),
					'Gains/Losses',MIN(t.VoidDate),@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-6,'G0', 'AP Gain/Loss'
			FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
				LEFT JOIN (SELECT d.DistCode, D.[Desc], G.CurrencyId FROM dbo.tblApDistCode D 
				INNER JOIN dbo.tblGlAcctHdr G ON G.AcctId = D.PayablesGLAcct) dc ON c.DistCode = dc.DistCode			
			WHERE c.CurrencyID <> @CurrBase AND c.PmtType = 0 AND c.ExchRate <> ISNULL(c.PmtExchRate, 1) 
			GROUP BY  c.vendorId, c.PmtType, c.DistCode, c.CurrencyId, c.PmtCurrencyId, c.VoidBankId
				,c.GLAcctGainLoss, dc.CurrencyId,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum,t.[Status]
			HAVING t.[Status] = 0
			UNION ALL
			SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,40,c.GLAcctGainLoss,
					(ROUND((c.GrossAmtDueFgn - c.DiscTakenFgn) / c.PmtExchRate, @PrecCurr) 
						- ((c.BaseGrossAmtDue) - ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr))),
					'Gains/Losses',t.VoidDate,@CurrBase,1,@CompId,c.VoidBankId, c.DistCode,0,0,0,0,c.CheckNum,-6,'G0', 'AP Gain/Loss'
			FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
				LEFT JOIN (SELECT d.DistCode, D.[Desc], G.CurrencyId FROM dbo.tblApDistCode D 
				INNER JOIN dbo.tblGlAcctHdr G ON G.AcctId = D.PayablesGLAcct) dc ON c.DistCode = dc.DistCode			
			WHERE c.CurrencyID <> @CurrBase AND c.PmtType = 3 AND c.ExchRate <> ISNULL(c.PmtExchRate, 1) 
			AND t.[Status] = 0 
		END
		ELSE
		BEGIN
			INSERT #VoidGlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,[Description],
				TransDate,CurrencyId,ExchRate,CompId,BankId,DistCode,DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,LinkID,LinkIDSubLine,SourceCode,Reference)
			SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,40,c.GLAcctGainLoss,
					SUM((ROUND((c.GrossAmtDueFgn - c.DiscTakenFgn) / c.PmtExchRate, @PrecCurr))
						- ((c.BaseGrossAmtDue) - ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr))),
					'Gains/Losses Sum',MIN(t.VoidDate),@CurrBase,1,@CompId,'', c.DistCode,0,0,0,0,c.CheckNum,-6,'G0', 'AP Gain/Loss'
			FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
				LEFT JOIN (SELECT d.DistCode, D.[Desc], G.CurrencyId FROM dbo.tblApDistCode D 
				INNER JOIN dbo.tblGlAcctHdr G ON G.AcctId = D.PayablesGLAcct) dc ON c.DistCode = dc.DistCode			
			WHERE c.CurrencyID <> @CurrBase AND c.PmtType = 0 AND c.ExchRate <> ISNULL(c.PmtExchRate, 1) 
			GROUP BY  c.PmtType, c.DistCode, c.CurrencyId, c.PmtCurrencyId,c.GLAcctGainLoss, dc.CurrencyId,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum,t.[Status]
			HAVING t.[Status] = 0
			UNION ALL
			SELECT @PostRun,t.VoidFiscalYear,t.VoidFiscalPeriod,40,c.GLAcctGainLoss,
					SUM((ROUND((c.GrossAmtDueFgn - c.DiscTakenFgn) / c.PmtExchRate, @PrecCurr))
					- ((c.BaseGrossAmtDue) - ROUND((c.DiscTakenFgn / c.ExchRate), @PrecCurr))),
					'Gains/Losses Sum',MIN(t.VoidDate),@CurrBase,1,@CompId,'', c.DistCode,0,0,0,0,c.CheckNum,-6,'G0', 'AP Gain/Loss'
			FROM #PostTransList t INNER JOIN dbo.tblApCheckHist c ON t.TransId = c.Counter
				LEFT JOIN (SELECT d.DistCode, D.[Desc], G.CurrencyId FROM dbo.tblApDistCode D 
				INNER JOIN dbo.tblGlAcctHdr G ON G.AcctId = D.PayablesGLAcct) dc ON c.DistCode = dc.DistCode			
			WHERE c.CurrencyID <> @CurrBase AND c.PmtType = 3 AND c.ExchRate <> ISNULL(c.PmtExchRate, 1)  
			GROUP BY  c.PmtType, c.DistCode, c.CurrencyId, c.PmtCurrencyId, c.GLAcctGainLoss, dc.CurrencyId,t.VoidFiscalYear,t.VoidFiscalPeriod,c.CheckNum,t.[Status]
			HAVING t.[Status] = 0
		END
	END

	UPDATE #VoidGlPostLogs SET  DebitAmount = CASE WHEN AmountFgn < 0 THEN ABS(ROUND(AmountFgn/ExchRate,@PrecCurr)) ELSE 0 END
		, CreditAmount = CASE WHEN AmountFgn > 0 THEN ROUND(AmountFgn/ExchRate,@PrecCurr) ELSE 0 END
		, DebitAmountFgn = CASE WHEN AmountFgn < 0 THEN -AmountFgn ELSE 0 END
		, CreditAmountFgn = CASE WHEN AmountFgn > 0 THEN AmountFgn ELSE 0 END 
		, PostDate = @WksDate
	WHERE DebitAmount = 0 AND CreditAmount = 0 
	
	IF @ApDetail = 1
	BEGIN
			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BankId,LinkID,LinkIDSubLine)
			SELECT PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BankId,LinkID,LinkIDSubLine
			FROM #VoidGlPostLogs
			WHERE (DebitAmount <> 0 OR CreditAmount <> 0) 
	END
	ELSE
	BEGIN
			INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
				CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkIDSubLine)
			SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(AmountFgn), 'AP', 
				CASE [Grouping] WHEN 10 THEN 'AP' WHEN 20 THEN @DiscountDescr WHEN 30 THEN @CashDescr ELSE NULL END,
				SUM(DebitAmount), SUM(CreditAmount),	SUM(DebitAmountfgn), SUM(CreditAmountfgn), 'AP', @WksDate, @WksDate, @CurrBase, 1, @CompId, -2
			FROM #VoidGlPostLogs
			GROUP BY GlAccount, FiscalPeriod, FiscalYear, [Grouping],
				CASE [Grouping] WHEN 10 THEN 'AP' WHEN 20 THEN @DiscountDescr WHEN 30 THEN @CashDescr ELSE NULL END
			HAVING SUM(DebitAmount) <> 0 OR SUM(CreditAmount) <> 0 
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVoidPaymentWrite_GlLog_proc';


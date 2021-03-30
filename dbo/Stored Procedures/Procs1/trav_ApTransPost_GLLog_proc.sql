
CREATE PROCEDURE dbo.trav_ApTransPost_GLLog_proc
AS
BEGIN TRY
	DECLARE @PostRun nvarchar(14), @TransAllocYn bit, @CurrBase pCurrency, @WrkStnDate datetime,
	@FreightDescr nvarchar(30), @MiscDescr nvarchar(30),	@InHsVendor pVendorID,@ApJcYn bit,
	@Multicurr bit, @ApDetail bit, @PrecCurr smallint,@CompId nvarchar(3)

	CREATE TABLE #ApTransPostLogDtl
	(
		[PostRun] [dbo].[pPostRun] NULL,
		[GlPeriod] [smallint] NULL,
		[TransId] [dbo].[pTransID] NULL,
		[EntryNum] [int] NULL,
		[Grouping] [smallint] NULL,
		[Amount] [dbo].[pDecimal] NOT NULL DEFAULT (0),
		[AmountFgn] [dbo].[pDecimal] NOT NULL DEFAULT (0),
		[TransDate] [datetime] NULL,
		[PostDate] [datetime] NULL,
		[Descr] [nvarchar](30) NULL,
		[SourceCode] [nvarchar](2) NULL,
		[Reference] [nvarchar](15) NULL,
		[DistCode] [dbo].[pDistCode] NULL,
		[GlAcct] [dbo].[pGlAcct] NULL,
		[DR] [dbo].[pDecimal] NULL,
		[CR] [dbo].[pDecimal] NULL,
		[Year] [smallint] NULL,
		[PayablesGlAcct] [dbo].[pGlAcct] NULL,
		[LinkID] [nvarchar](15) NULL,
		[LinkIDSub] [nvarchar](15) NULL,
		[LinkIDSubLine] [int] NULL DEFAULT (0),
		[CurrencyId] [dbo].[pCurrency] NULL,
		[ExchRate] [dbo].[pDecimal] NULL DEFAULT (1),
		[DebitAmtFgn] [dbo].[pDecimal] NULL DEFAULT (0),
		[CreditAmtFgn] [dbo].[pDecimal] NULL DEFAULT (0)
	)

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @TransAllocYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'TransAllocYn'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @FreightDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'FreightDescr'
	SELECT @MiscDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'MiscDescr'
	SELECT @Multicurr = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @ApDetail = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApDetail'
	SELECT @PrecCurr = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @ApJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApJcYn'
	SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'

	IF @PostRun IS NULL OR @CurrBase IS NULL OR @TransAllocYn IS NULL OR @WrkStnDate IS NULL 
		OR @FreightDescr IS NULL OR @MiscDescr IS NULL 
		OR @Multicurr IS NULL OR @ApDetail IS NULL OR @PrecCurr IS NULL OR @ApJcYn IS NULL OR @CompId IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	SET @InHsVendor = ISNULL(@InHsVendor,'')

	SELECT dbo.tblApTransHeader.FiscalYear [Year], dbo.tblApTransHeader.GLPeriod, dbo.tblApTransHeader.DistCode
		, dbo.tblApTransHeader.TransId, dbo.tblApTransDetail.EntryNum, dbo.tblApTransDetail.GLDesc, dbo.tblApTransHeader.TransType
		, dbo.tblApTransHeader.VendorId, dbo.tblApTransHeader.InvoiceNum
		, CASE WHEN dbo.tblGlAcctHdr.CurrencyId <> @CurrBase THEN  dbo.tblApTransHeader.CurrencyId ELSE @CurrBase END CurrencyId
		, CASE WHEN dbo.tblGlAcctHdr.CurrencyId <> @CurrBase THEN dbo.tblApTransHeader.ExchRate ELSE 1 END ExchRate
		, dbo.tblApTransHeader.InvoiceDate, dbo.tblApTransHeader.SalesTax, dbo.tblApTransHeader.Freight, dbo.tblApTransHeader.FreightFgn
		, dbo.tblApTransHeader.Misc, dbo.tblApTransHeader.MiscFgn, dbo.tblApTransHeader.TaxAdjAmt, dbo.tblApTransHeader.TaxAdjAmtFgn
		, dbo.tblApTransHeader.TaxAdjClass,tblApTransHeader.TaxAdjLocID, dbo.tblApTransDetail.GLAcct
		, dbo.tblApTransDetail.ExtCost, dbo.tblApTransDetail.ExtCostFgn, dbo.tblApDistCode.PayablesGLAcct
		, dbo.tblApDistCode.SalesTaxGLAcct, dbo.tblApDistCode.FreightGLAcct, dbo.tblApDistCode.MiscGLAcct
		, dbo.tblApTransDetail.[Desc] Descr, dbo.tblApTransDetail.TransHistId 
	INTO #Temp1 
	FROM ((dbo.tblApDistCode INNER JOIN dbo.tblApTransHeader ON dbo.tblApDistCode.DistCode = dbo.tblApTransHeader.DistCode) 
		LEFT JOIN dbo.tblGlAcctHdr ON  dbo.tblApDistCode.PayablesGLAcct =  dbo.tblGlAcctHdr.AcctId 
		LEFT JOIN dbo.tblApTransDetail ON dbo.tblApTransHeader.TransId = dbo.tblApTransDetail.TransID) 
		INNER JOIN #PostTransList l ON dbo.tblApTransHeader.TransId = l.TransId
	ORDER BY dbo.tblApTransHeader.GLPeriod, dbo.tblApTransHeader.DistCode, dbo.tblApTransHeader.TransId, dbo.tblApTransDetail.EntryNum

	IF @TransAllocYn = 0 
	BEGIN
		-- purge any allocation data if not using transaction allocations so they aren't used for updating the posting logs
		DELETE dbo.tblApTransAlloc FROM dbo.tblApTransAlloc 
			INNER JOIN dbo.tblApTransHeader th ON dbo.tblApTransAlloc.TransId = th.TransId 
			INNER JOIN #PostTransList l ON th.TransId = l.TransId 
	END

	-- insert Line Number detail - left join with tblApTransAllocDtl for allocations
	INSERT #ApTransPostLogDtl (PostRun, GlPeriod, TransId, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT @PostRun, GlPeriod, #Temp1.TransId, #Temp1.EntryNum, 10
		, SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END
		, CASE WHEN  #Temp1.CurrencyId <> @CurrBase 
			THEN (SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCostFgn ELSE a.AmountFgn END) 
			ELSE (SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END) END
		, InvoiceDate, @WrkStnDate
		, CASE WHEN GlDesc IS NOT NULL THEN CONVERT(nvarchar(30), GlDesc) 
			WHEN #Temp1.Descr IS NOT NULL THEN CONVERT(nvarchar(30), #Temp1.Descr ) ELSE InvoiceNum END
		, 'AP', VendorId, #Temp1.DistCode
		, CASE WHEN a.TransId IS NULL THEN #Temp1.GlAcct ELSE a.AcctId END
		, CASE WHEN SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END > 0 
			THEN ABS(CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END) ELSE 0 END
		, CASE WHEN SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END < 0 
			THEN ABS(CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END) ELSE 0 END
		, [Year], PayablesGlAcct, #Temp1.TransID, InvoiceNum, #Temp1.EntryNum
		, @CurrBase,  #Temp1.ExchRate
		, CASE WHEN SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END > 0 
			THEN ABS(CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END) ELSE 0 END DebitAmtFgn
		, CASE WHEN SIGN(TransType) * CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END < 0 
			THEN ABS(CASE WHEN a.TransId IS NULL THEN ExtCost ELSE a.Amount END) ELSE 0 END CreditAmtFgn 
	FROM #Temp1 LEFT JOIN dbo.tblApTransAllocDtl a ON #Temp1.TransId = a.TransId AND #Temp1.EntryNum = a.EntryNum 
	WHERE #Temp1.EntryNum IS NOT NULL AND ExtCost <> 0

	-- tax locations
	-- tax adjustments
	INSERT #ApTransPostLogDtl (PostRun,GlPeriod, TransId, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun,GLPeriod, #Temp1.TransId, 99999, 101, (SIGN(TransType) * TaxAdjAmt) Amount
		, (SIGN(TransType) * TaxAdjAmtfgn) Amountfgn, InvoiceDate, @WrkStnDate, 'TaxLoc ' + TaxAdjLocID + ' ' + CONVERT(nvarchar,TaxAdjClass)
		, 'AP', VendorID, DistCode, CASE WHEN ExpenseAcct IS NULL THEN PayablesGLAcct ELSE ExpenseAcct END
		, CASE WHEN SIGN(TransType) * TaxAdjAmt > 0 THEN ABS(TaxAdjAmt) ELSE 0 END
		, CASE WHEN SIGN(TransType) * TaxAdjAmt < 0 THEN ABS(TaxAdjAmt) ELSE 0 END
		, [Year], PayablesGlAcct, #Temp1.TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN SIGN(TransType) * TaxAdjAmt > 0 THEN ABS(TaxAdjAmt) ELSE 0 END
		, CASE WHEN SIGN(TransType) * TaxAdjAmt < 0 THEN ABS(TaxAdjAmt) ELSE 0 END 
	FROM dbo.tblSmTaxLocDetail 
		INNER JOIN #Temp1 ON dbo.tblSmTaxLocDetail.TaxClassCode = #Temp1.TaxAdjClass 
			AND dbo.tblSmTaxLocDetail.TaxLocId = #Temp1.TaxAdjLocID 
	WHERE TaxAdjAmt <> 0

	-- tax levels
	INSERT #ApTransPostLogDtl (PostRun, GlPeriod, TransId, EntryNum, [Grouping], Amount,  AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun, GlPeriod, t.TransID, 99999, 101, (SIGN(TransType) * TaxAmt), (SIGN(TransType) * TaxAmtfgn)
		, InvoiceDate, @WrkStnDate, 'TaxLoc ' + t.TaxLocID + ' ' + CONVERT(nvarchar, T.TaxClass)
		,'AP', VendorID, DistCode, t.ExpAcct
		, CASE WHEN SIGN(TransType) * TaxAmt > 0 THEN ABS(TaxAmt) ELSE 0 END
		, CASE WHEN SIGN(TransType) * TaxAmt < 0 THEN ABS(TaxAmt) ELSE 0 END
		, [Year], PayablesGlAcct, t.TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN SIGN(TransType) * TaxAmt > 0 THEN ABS(TaxAmt) ELSE 0 END
		, CASE WHEN SIGN(TransType) * TaxAmt < 0 THEN ABS(TaxAmt) ELSE 0 END 
	FROM dbo.tblApTransInvoiceTax T	INNER JOIN #Temp1 ON t.TransId = #Temp1.TransId 
	WHERE TaxAmt <> 0

	-- tax refund
	INSERT #ApTransPostLogDtl (PostRun, GlPeriod, TransId, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct,LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun, GlPeriod, t.TransID, 99999, 101, (SIGN(TransType) * Refundable) * -1 Amount
		, (SIGN(TransType) * Refundablefgn) * -1 AmountFgn, InvoiceDate, @WrkStnDate, 'Tax Refund ' + t.TaxLocID
		, 'AP', VendorID,DistCode, t.ExpAcct
		, CASE WHEN (SIGN(TransType) * Refundable) * -1 > 0 THEN ABS(Refundable) ELSE 0 END
		, CASE WHEN (SIGN(TransType) * Refundable) * -1 < 0 THEN ABS(Refundable) ELSE 0 END
		, [Year], PayablesGlAcct, t.TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN (SIGN(TransType) * Refundable) * -1 > 0 THEN ABS(Refundable) ELSE 0 END
		, CASE WHEN (SIGN(TransType) * Refundable) * -1 < 0 THEN ABS(Refundable) ELSE 0 END 
	FROM dbo.tblApTransInvoiceTax T	INNER JOIN #Temp1 ON t.TransId = #Temp1.TransId 
	WHERE Refundable <> 0
	
	INSERT #ApTransPostLogDtl (PostRun, GlPeriod, TransId, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct,LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun, GlPeriod, t.TransID, 99999, 101, (SIGN(TransType) * Refundable) Amount
		, (SIGN(TransType) * Refundablefgn) AmountFgn, InvoiceDate, @WrkStnDate, 'Tax Refund ' + t.TaxLocID
		, 'AP', VendorID,DistCode, t.RefundAcct
		, CASE WHEN (SIGN(TransType) * Refundable) > 0 THEN ABS(Refundable) ELSE 0 END
		, CASE WHEN (SIGN(TransType) * Refundable) < 0 THEN ABS(Refundable) ELSE 0 END
		, [Year], PayablesGlAcct, t.TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN (SIGN(TransType) * Refundable) > 0 THEN ABS(Refundable) ELSE 0 END
		, CASE WHEN (SIGN(TransType) * Refundable) < 0 THEN ABS(Refundable) ELSE 0 END 
	FROM dbo.tblApTransInvoiceTax T	INNER JOIN #Temp1 ON t.TransId = #Temp1.TransId 
	WHERE Refundable <> 0

	-- insert freight and misc amounts
	INSERT #ApTransPostLogDtl (PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun, TransId, GlPeriod, 100000, 102, SIGN(TransType) * Freight, SIGN(TransType) * Freightfgn
		, InvoiceDate, @WrkStnDate, @FreightDescr, 'AP', VendorId, #Temp1.DistCode, FreightGLAcct
		, CASE WHEN SIGN(TransType) * Freight > 0 THEN ABS(Freight) ELSE 0 END
		, CASE WHEN SIGN(TransType) * Freight < 0 THEN ABS(Freight) ELSE 0 END
		, [Year], PayablesGlAcct, TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN SIGN(TransType) * Freight > 0 THEN ABS(Freight) ELSE 0 END
		, CASE WHEN SIGN(TransType) * Freight < 0 THEN ABS(Freight) ELSE 0 END 
	FROM #Temp1 
	WHERE Freight <> 0

	INSERT #ApTransPostLogDtl (PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate, Descr
		, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
	SELECT DISTINCT @PostRun, TransId, GlPeriod, 100000, 103, SIGN(TransType) * Misc, SIGN(TransType) * Miscfgn
		, InvoiceDate, @WrkStnDate, @MiscDescr, 'AP', VendorId, #Temp1.DistCode, MiscGLAcct
		, CASE WHEN SIGN(TransType) * Misc > 0 THEN ABS(Misc) ELSE 0 END
		, CASE WHEN SIGN(TransType) * Misc < 0 THEN ABS(Misc) ELSE 0 END
		, [Year], PayablesGlAcct, TransID, InvoiceNum, 0, @CurrBase, #Temp1.ExchRate
		, CASE WHEN SIGN(TransType) * Misc > 0 THEN ABS(Misc) ELSE 0 END
		, CASE WHEN SIGN(TransType) * Misc < 0 THEN ABS(Misc) ELSE 0 END 
	FROM #Temp1 
	WHERE Miscfgn <> 0

	IF @Multicurr = 1
	BEGIN
		INSERT #ApTransPostLogDtl (PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate
			, Descr, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct
			, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
		SELECT  e.PostRun, '00000000' TransId, e.GlPeriod, e.EntryNum, e.[Grouping], e.Amount, e.AmountFgn, e.TransDate, e.PostDate
			, e.Descr, e.SourceCode, e.Reference, e.DistCode, e.GlAcct, e.DR, e.CR, e.[Year], e.PayablesGlAcct
			, e.CurrencyId, e.ExchRate, e.DebitAmtFgn, e.CreditAmtFgn 
		FROM (SELECT DISTINCT  @PostRun PostRun, TransId, #ApTransPostLogDtl.GlPeriod, 100000  EntryNum, 104 [Grouping]
				, SUM(-1 * Amount) Amount, CASE WHEN  g.CurrencyId <> @CurrBase 
					THEN SUM(-1 * AmountFgn) ELSE SUM(-1 * Amount) END AmountFgn
				, MAX(TransDate) TransDate, @WrkStnDate PostDate, 'AP' Descr, 'AP' SourceCode, 'AP' Reference
				, ' ' DistCode, #ApTransPostLogDtl.PayablesGlAcct GlAcct
				, CASE WHEN SUM(-1 * Amount) > 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END DR
				, CASE WHEN SUM(-1 * Amount) < 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END CR
				, #ApTransPostLogDtl.[Year], ' ' PayablesGlAcct
				, ISNULL(g.CurrencyId, @CurrBase) CurrencyId, ExchRate
				, CASE WHEN ISNULL(g.CurrencyId, @CurrBase) <> @CurrBase 
					THEN (CASE WHEN SUM(-1 * AmountFgn) > 0 THEN ABS(SUM(-1 * AmountFgn)) ELSE 0 END) 
					ELSE (CASE WHEN SUM(-1 * Amount) > 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END) END DebitAmtFgn
				, CASE WHEN ISNULL(g.CurrencyId, @CurrBase) <> @CurrBase 
					THEN (CASE WHEN SUM(-1 * AmountFgn) < 0 THEN ABS(SUM(-1* AmountFgn)) ELSE 0 END) 
					ELSE (CASE WHEN SUM(-1 * Amount) < 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END) END CreditAmtFgn 
			FROM #ApTransPostLogDtl 
				LEFT JOIN dbo.tblGlAcctHdr g ON #ApTransPostLogDtl.PayablesGLAcct = g.AcctId 
			WHERE #ApTransPostLogDtl.PayablesGlAcct IS NOT NULL 
			GROUP BY #ApTransPostLogDtl.[Year], #ApTransPostLogDtl.GlPeriod, #ApTransPostLogDtl.PayablesGlAcct
				, g.CurrencyId,  #ApTransPostLogDtl.TransId, #ApTransPostLogDtl.ExchRate 
			HAVING SUM(-1 * Amount) <> 0 ) e

		UPDATE #ApTransPostLogDtl 
		SET #ApTransPostLogDtl.ExchRate = CASE WHEN (CurrencyId = @CurrBase OR CurrencyId = '1' ) THEN 1 ELSE ExchRate END
			, #ApTransPostLogDtl.AmountFgn = CASE WHEN (CurrencyId = @CurrBase) THEN #ApTransPostLogDtl.Amount 
				ELSE #ApTransPostLogDtl.Amountfgn END 
	END

	ELSE

	BEGIN
		INSERT #ApTransPostLogDtl (PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, AmountFgn, TransDate, PostDate
			, Descr, SourceCode, Reference, DistCode, GlAcct, DR, CR, [Year], PayablesGlAcct
			, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn) 
		SELECT  e.PostRun, e.TransId, e.GlPeriod, e.EntryNum, e.[Grouping], e.Amount, e.AmountFgn, e.TransDate, e.PostDate
			, e.Descr, e.SourceCode, e.Reference, e.DistCode, e.GlAcct, e.DR, e.CR, e.[Year], e.PayablesGlAcct
			, e.CurrencyId, e.ExchRate, e.DebitAmtFgn, e.CreditAmtFgn 
		FROM (SELECT DISTINCT @PostRun PostRun, '00000000' TransId, #ApTransPostLogDtl.GlPeriod, 100000  EntryNum
				, 104 [Grouping], SUM(-1 * Amount) Amount, SUM(-1 * Amountfgn) AmountFgn
				, @WrkStnDate TransDate, @WrkStnDate PostDate, 'AP' Descr, 'AP' SourceCode, 'AP' Reference
				, ' ' DistCode, #ApTransPostLogDtl.PayablesGlAcct GlAcct
				, CASE WHEN SUM(-1 * Amount) > 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END DR
				, CASE WHEN SUM(-1 * Amount) < 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END CR
				, #ApTransPostLogDtl.[Year], ' ' PayablesGlAcct
				, @CurrBase AS CurrencyId, 1 AS ExchRate
				, CASE WHEN SUM(-1 * Amount) > 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END DebitAmtFgn
				, CASE WHEN SUM(-1 * Amount) < 0 THEN ABS(SUM(-1 * Amount)) ELSE 0 END  CreditAmtFgn 
			FROM #ApTransPostLogDtl 
				LEFT JOIN dbo.tblAPDistCode d ON #ApTransPostLogDtl.DistCode = d.DistCode 
				LEFT JOIN dbo.tblGlAcctHdr g ON d.PayablesGLAcct = g.AcctId 
			WHERE #ApTransPostLogDtl.PayablesGlAcct IS NOT NULL 
			GROUP BY #ApTransPostLogDtl.[Year], #ApTransPostLogDtl.GlPeriod, #ApTransPostLogDtl.PayablesGlAcct 
			HAVING SUM(-1 * Amount) <> 0 ) e
	END

	IF (@ApJcYn = 1) --remove line item entry if it is a project line item after summarize amount for AP account
	BEGIN
		DELETE #ApTransPostLogDtl 
		FROM #ApTransPostLogDtl	INNER JOIN dbo.tblApTransPc p ON #ApTransPostLogDtl.TransId = p.TransId AND #ApTransPostLogDtl.EntryNum = p.EntryNum 
		WHERE #ApTransPostLogDtl.[Grouping] = 10
	END
	
	IF (@ApDetail = 0)
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, [Year], GlPeriod, [Grouping], GlAcct, SUM(Amount), 'AP'
			, CASE WHEN [Grouping] = 101 THEN 'Sales Tax' WHEN [Grouping] = 102 THEN 'Freight' 
				WHEN [Grouping] = 103 THEN 'Misc' WHEN [Grouping] = 104 THEN 'AP' 
				WHEN [Grouping] = 10 THEN 'AP Line Items' ELSE '??????' END
			, CASE WHEN SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END DR
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END CR
			, CASE WHEN SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END DR
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END CR		
			, 'AP' SourceCode, @WrkStnDate PostDate	, @WrkStnDate TransDate,@CurrBase,1,@CompId
		FROM  #ApTransPostLogDtl
		GROUP BY  #ApTransPostLogDtl.[Year],  #ApTransPostLogDtl.GlPeriod
			, #ApTransPostLogDtl.[Grouping],  #ApTransPostLogDtl.GlAcct
			, CASE WHEN [Grouping] = 101 THEN 'Sales Tax' WHEN [Grouping] = 102 THEN 'Freight' 
				WHEN [Grouping] = 103 THEN 'Misc' WHEN [Grouping] = 104 THEN 'AP' 
				WHEN [Grouping] = 10 THEN 'AP Line Items' ELSE '????????' END 
		ORDER BY  #ApTransPostLogDtl.[Year], #ApTransPostLogDtl.GlPeriod, #ApTransPostLogDtl.[Grouping]
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT @PostRun, [Year], GlPeriod, [Grouping], GlAcct,AmountFgn,Reference,Descr,DR,
			CR,DebitAmtFgn,CreditAmtFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,@CompId, LinkID, LinkIDSub, LinkIDSubLine
		FROM  #ApTransPostLogDtl
	END

	-- update main log table 
	INSERT #ApTransPostVendorLog( FiscalYear, FiscalPeriod, CurrencyId, VendorTableAmount, OpenInvoiceTableAmount, VendorTableAmountFgn, OpenInvoiceTableAmountFgn)
	SELECT h.FiscalYear, h.GlPeriod, h.CurrencyId, SUM((SIGN(h.TransType)) * (h.Subtotal + h.SalesTax + h.Freight + h.Misc + h.TaxAdjAmt)) AS VendorTableAmount, 
		SUM((SIGN(h.TransType)) * (h.PmtAmt1 + h.PmtAmt2 + h.PmtAmt3 + h.PrepaidAmt + h.CashDisc)) AS OpenInvoiceTableAmount,
		SUM((SIGN(h.TransType)) * (h.SubtotalFgn + h.SalesTaxFgn + h.FreightFgn + h.MiscFgn + h.TaxAdjAmtfgn)) AS VendorTableAmountFgn,
		SUM((SIGN(h.TransType)) * (h.PmtAmt1fgn + h.PmtAmt2Fgn + h.PmtAmt3fgn + h.PrepaidAmtfgn + h.CashDiscfgn)) AS OpenInvoiceTableAmountFgn
	FROM dbo.tblApTransHeader h INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE (@ApJcYn = 0 OR h.VendorID <> @InHsVendor)
	GROUP BY h.FiscalYear, h.GLPeriod, h.CurrencyId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_GLLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_GLLog_proc';


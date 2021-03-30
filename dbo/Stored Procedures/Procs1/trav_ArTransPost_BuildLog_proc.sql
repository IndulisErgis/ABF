
CREATE PROCEDURE dbo.trav_ArTransPost_BuildLog_proc
AS
BEGIN TRY
	DECLARE	@PostRun pPostRun
	, @MCYn bit
	, @ArGlYn bit
	, @ArInYn bit
	, @ArJcYn bit
	, @ArGlDetailYn bit
	, @PostGainLossDtl bit
	, @CurrBase pCurrency
	, @PrecCurr smallint
	, @CompId [sysname]     
	, @WrkStnDate datetime
	, @SalesDescr nvarchar(30)
	, @InventoryDescr nvarchar(30)
	, @COGSDescr nvarchar(30)
	, @SalesTaxDescr nvarchar(30)
	, @FreightDescr nvarchar(30)
	, @MiscDescr nvarchar(30)
	, @ARDescr nvarchar(30)
	, @UnknownDescr nvarchar(30)

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @ArInYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArInYn'
	SELECT @ArJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArJcYn'
	SELECT @ArGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlDetailYn'
	SELECT @PostGainLossDtl = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostGainLossDtl'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @SalesDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'SalesDescr'
	SELECT @InventoryDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'InventoryDescr'
	SELECT @COGSDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'COGSDescr'
	SELECT @SalesTaxDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'SalesTaxDescr'
	SELECT @FreightDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'FreightDescr'
	SELECT @MiscDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'MiscDescr'
	SELECT @ARDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'ARDescr'
	SELECT @UnknownDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'UnknownDescr'

	IF @PostRun IS NULL OR @MCYn IS NULL 
		OR @ArGlYn IS NULL OR @ArInYn IS NULL OR @ArJcYn IS NULL OR @ArGlDetailYn IS NULL 
		OR @PostGainLossDtl IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL 
		OR @WrkStnDate IS NULL 
		OR @SalesDescr IS NULL OR @InventoryDescr IS NULL OR @COGSDescr IS NULL OR @SalesTaxDescr IS NULL 
		OR @FreightDescr IS NULL OR @MiscDescr IS NULL OR @ARDescr IS NULL OR @UnknownDescr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #ArTransPostLogDtl 
	(
		[Counter] int Not Null Identity(1, 1), 
		[PostRun] pPostRun Not Null, 
		[TransId] pTransId Null, 
		[EntryNum] int Null, 
		[Grouping] smallint Null, 
		[Amount] pDecimal Not Null, 
		[TransDate] datetime Null, 
		[PostDate] datetime Null, 
		[Descr] nvarchar(30) Null, 
		[SourceCode] nvarchar(2) Null, 
		[Reference] nvarchar(15) Null, 
		[DistCode] pDistCode Null,
		[GlAcct] pGlAcct Null, 
		[DR] pDecimal Null, 
		[CR] pDecimal Null, 
		[FiscalPeriod] smallint Null, 
		[FiscalYear] smallint Null, 
		[LinkID] nvarchar(15) Null, 
		[LinkIDSub] nvarchar(15) Null, 
		[LinkIDSubLine] int Null, 
		[CurrencyId] pCurrency Null, 
		[ExchRate] pDecimal Null Default(1), 
		[DebitAmtFgn] pDecimal Null Default(0), 
		[CreditAmtFgn] pDecimal Null Default(0)
	)

	Create Table #Temp1
	(
		TransId pTransId,
		EntryNum int,
		FiscalYear smallint,
		GLPeriod smallint,
		TransType smallint,
		CustId pCustId Null,
		InvcNum pInvoiceNum Null,
		InvcDate datetime,
		TaxSubtotal pDecimal Null, 
		TaxSubtotalFgn pDecimal Null,   
		NonTaxSubtotal pDecimal Null,
		NonTaxSubtotalFgn pDecimal Null,
		SalesTax pDecimal Null,
		SalesTaxFgn pDecimal Null,
		Freight pDecimal Null,
		FreightFgn pDecimal Null,    
		Misc pDecimal Null,
		MiscFgn pDecimal Null,     
		TotCost pDecimal Null, 
		DistCode pDistCode Null,
		Descr pDescription, 
		GLAcctSales pGlAcct Null, 
		GLAcctCOGS pGlAcct Null, 
		GLAcctInv pGlAcct Null, 
		QtyShipSell pDecimal Null, 
		UnitPriceSell pDecimal Null, 
		UnitCostSell pDecimal Null, 
		ExtPrice pDecimal Null,
		ExtCost pDecimal Null,
		BatchId pBatchId Null, 
		GLAcctReceivables pGlAcct Null, 
		GLAcctFreight pGlAcct Null, 
		GLAcctMisc pGlAcct Null, 
		PartId pItemId Null, 
		TaxAmtAdj pDecimal Null,
		TaxAmtAdjFgn pDecimal Null, 
		TaxLocAdj pTaxLoc Null, 
		TaxClassAdj tinyint, 
		ExtFinalInc pDecimal Null, 
		ExtOrigInc pDecimal Null, 
		AcctCode pGLAcctCode Null, 
		PmTransType nvarchar(4),
		TransHistID nvarchar(8),
		CurrencyId pCurrency Null,    
		ExchRate pDecimal Null,
		OrgInvcExchRate pDecimal Null,
		InvcTotFgn pDecimal Null,
		InvcTot pDecimal Null
	)               

	Insert Into #Temp1 (TransId, EntryNum, FiscalYear, GLPeriod, TransType, CustId, InvcNum
		, CurrencyId, ExchRate, InvcDate, TaxSubtotal, TaxSubtotalFgn, NonTaxSubtotal, NonTaxSubtotalFgn 
		, SalesTax, SalesTaxFgn, Freight, FreightFgn
		, Misc, MiscFgn, TotCost, DistCode, Descr, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyShipSell, UnitPriceSell
		, UnitCostSell, ExtPrice, ExtCost, BatchId, GLAcctReceivables   
		, GLAcctFreight
		, GLAcctMisc, PartId, TaxAmtAdj, TaxAmtAdjFgn, TaxLocAdj, TaxClassAdj, ExtFinalInc
		, ExtOrigInc, AcctCode, PmTransType, TransHistId, OrgInvcExchRate, InvcTotFgn, InvcTot)
	SELECT th.TransId, td.EntryNum, th.FiscalYear, th.GLPeriod, th.TransType, th.CustId
		, ISNULL(th.InvcNum, l.DefaultInvoiceNumber)
		, th.CurrencyID, th.ExchRate, th.InvcDate, th.TaxSubtotal, th.TaxSubtotalFgn, th.NonTaxSubtotal
		, th.NonTaxSubtotalFgn, th.SalesTax, th.SalesTaxFgn, th.Freight, th.FreightFgn, th.Misc, th.MiscFgn
		, th.TotCost, th.DistCode, td.[Desc], td.GLAcctSales, td.GLAcctCOGS, td.GLAcctInv
		, td.QtyShipSell, td.UnitPriceSell, td.UnitCostSell   
		, td.PriceExt AS ExtPrice, td.CostExt AS ExtCost  
		, th.BatchId, dc.GLAcctReceivables, dc.GLAcctFreight
		, dc.GLAcctMisc, td.PartId, th.TaxAmtAdj, th.TaxAmtAdjFgn 
		, th.TaxLocAdj, th.TaxClassAdj
		, td.ExtFinalInc, td.ExtOrigInc, td.AcctCode, th.PmTransType, td.TransHistID, th.OrgInvcExchRate 
		, sign([TransType]) * (TaxSubtotalFgn+NonTaxSubtotalFgn+SalesTaxFgn+TaxAmtAdjFgn+FreightFgn+MiscFgn) AS InvcTotFgn
		, sign([TransType]) * (TaxSubtotal+NonTaxSubtotal+SalesTax+TaxAmtAdj+Freight+Misc) AS InvcTot  
	FROM dbo.tblArTransHeader th 
	INNER JOIN #PostTransList l ON th.TransId = l.TransId
	LEFT JOIN dbo.tblArTransDetail td ON th.TransId = td.TransID
	LEFT JOIN dbo.tblArDistCode dc ON th.DistCode = dc.DistCode
	ORDER BY th.TransId, td.EntryNum, th.GLPeriod   

	--retrieve currency from gl receivables account when mc is enabled
	IF @ArGlYn = 1 AND @MCYN = 1
	BEGIN
		UPDATE #Temp1 SET currencyid = g.CurrencyID 
		FROM #Temp1 INNER JOIN dbo.tblGlAcctHdr g 
			ON #Temp1.GLAcctReceivables = g.AcctId
	END

	--Line Sales
	INSERT INTO #ArTransPostLogDtl    
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, GlPeriod, TransId, #Temp1.EntryNum, 10
		, Convert(decimal(28,10), Sign(TransType)) * -1 * (ExtPrice)
		, InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(PartId, ''), 1, 30) END 
		, 'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctSales
		, CASE WHEN Sign(TransType) * -1 * (ExtPrice) > 0
			THEN ABS(ExtPrice) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtPrice) < 0
			THEN ABS(ExtPrice) ELSE 0 END
		, FiscalYear, TransID, InvcNum, EntryNum
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * -1 * (ExtPrice) > 0        
			THEN ABS(ExtPrice) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtPrice) < 0
			THEN ABS(ExtPrice) ELSE 0 END
	FROM #Temp1
	WHERE #Temp1.EntryNum IS NOT NULL AND (ExtPrice) <> 0

	--Inventory Sales
	INSERT #ArTransPostLogDtl
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)    
	SELECT @PostRun, GlPeriod, TransId, #Temp1.EntryNum, 11
		, Sign(TransType) * -1 * (ExtCost)
		, InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(PartId, ''), 1, 30) END 
		, 'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctInv
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) > 0
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
		, FiscalYear, TransID, InvcNum, EntryNum
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) > 0     
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
	FROM #Temp1
	WHERE #Temp1.EntryNum IS NOT NULL AND (ExtCost) <> 0


	--COGS
	INSERT #ArTransPostLogDtl
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, GlPeriod, TransId, #Temp1.EntryNum, 12, 
		Sign(TransType) * (ExtCost), InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(PartId, ''), 1, 30) END 
		, 'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctCOGS
		, CASE WHEN Sign(TransType) * (ExtCost) > 0
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
		, FiscalYear, TransID, InvcNum, EntryNum
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * (ExtCost) > 0   
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
	FROM #Temp1
	WHERE #Temp1.EntryNum IS NOT NULL AND (ExtCost) <> 0

--todo: enable JC code when application is available
	----PC/JC
	--IF @ArJcYn = 1
	--BEGIN
	--	-- WIP                  
	--	INSERT #ArTransPostLogDtl
	--		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
	--		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
	--		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
	--		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	--	SELECT  @PostRun, GlPeriod, TransId, EntryNum, 10, 
	--		Sign(TransType) * (ExtFinalInc - ExtOrigInc ), InvcDate, @WrkStnDate
	--		, CustId + '/' + InvcNum, 'AR', CustId, DistCode, GLAcctSales
	--		, CASE WHEN  Sign(TransType) * (ExtFinalInc - ExtOrigInc ) > 0
	--			THEN ABS(ExtFinalInc - ExtOrigInc) ELSE 0 END
	--		, CASE WHEN  Sign(TransType) * (ExtFinalInc - ExtOrigInc ) < 0
	--			THEN ABS(ExtFinalInc - ExtOrigInc) ELSE 0 END
	--		, FiscalYear, TransID, InvcNum, EntryNum
	--		, @CurrBase, 1.0
	--		, CASE WHEN  Sign(TransType) * (ExtFinalInc - ExtOrigInc ) > 0
	--			THEN ABS(ExtFinalInc - ExtOrigInc) ELSE 0 END
	--		, CASE WHEN  Sign(TransType) * (ExtFinalInc - ExtOrigInc ) < 0
	--			THEN ABS(ExtFinalInc - ExtOrigInc) ELSE 0 END
	--	FROM #Temp1 
	--	WHERE EntryNum IS NOT NULL AND LEFT(PmTransType,3) = 'WIP' AND ExtFinalInc <> ExtOrigInc 

	--	-- Adjust
	--	INSERT #ArTransPostLogDtl     
	--		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
	--		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
	--		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
	--		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	--	SELECT  @PostRun, a.GlPeriod, a.TransId, a.EntryNum, 10
	--		, -1 * Sign(a.TransType) * (a.ExtFinalInc - a.ExtOrigInc )
	--		, a.InvcDate, @WrkStnDate, a.CustId + '/' + a.InvcNum
	--		, 'AR', a.CustId, a.DistCode, b.GLAcctAdjust
	--		, CASE WHEN -1 * Sign(a.TransType) * (a.ExtFinalInc - a.ExtOrigInc ) > 0
	--			THEN ABS(a.ExtFinalInc - a.ExtOrigInc) ELSE 0 END
	--		, CASE WHEN -1 * Sign(a.TransType) * (a.ExtFinalInc - a.ExtOrigInc ) < 0
	--			THEN ABS(a.ExtFinalInc - a.ExtOrigInc) ELSE 0 END
	--		, a.FiscalYear, a.TransID, a.InvcNum, a.EntryNum
	--		, @CurrBase, 1.0
	--		, CASE WHEN -1 * Sign(a.TransType) * (a.ExtFinalInc - a.ExtOrigInc ) > 0
	--			THEN ABS(a.ExtFinalInc - a.ExtOrigInc) ELSE 0 END
	--		, CASE WHEN -1 * Sign(a.TransType) * (a.ExtFinalInc - a.ExtOrigInc ) < 0
	--			THEN ABS(a.ExtFinalInc - a.ExtOrigInc) ELSE 0 END
	--		FROM #Temp1 a INNER JOIN dbo.tblJCTransHistory b ON a.TransHistID = b.TransHistID
	--	WHERE a.EntryNum IS NOT NULL AND LEFT(a.PmTransType,3) = 'WIP' AND a.ExtFinalInc <> a.ExtOrigInc 
	--END

	--Tax Locations
	Create Table #zzTax
	(
		TransId pTransId, 
		InvcNum pInvoiceNum Null, 
		FiscalYear smallint, 
		GLPeriod smallint, 
		TaxAmount pDecimal Null,
		InvcDate datetime,
		TaxLocID pTaxLoc Null,
		CustID pCustId Null, 
		DistCode pDistCode Null, 
		LiabilityAcct pGlAcct Null
	)
                        
	--tax detail                                         
	INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, GLPeriod, TaxAmount
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct)
		SELECT h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), h.FiscalYear, h.GLPeriod
			, Sign(h.TransType) * -1 * TaxAmt
			, h.InvcDate, t.TaxLocID, h.CustID, h.DistCode, t.LiabilityAcct
		FROM dbo.tblArTransHeader h 
		INNER JOIN dbo.tblArTransTax t ON h.TransId = t.TransId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE t.TaxAmt <> 0
			
	--tax adjustments
	INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, GLPeriod, TaxAmount
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct)
		SELECT h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), h.FiscalYear, h.GLPeriod
			, Sign(h.TransType) * -1 * TaxAmtAdj
			, h.InvcDate, h.TaxLocAdj, h.CustID, h.DistCode, t.GlAcct
		FROM dbo.tblArTransHeader h 
		LEFT JOIN dbo.tblSmTaxLoc t on h.TaxLocAdj = t.TaxLocId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE TaxAmtAdj <> 0

	INSERT #ArTransPostLogDtl        
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, TransID, GlPeriod, 100000,101
			, SUM(TaxAmount)
			, InvcDate, @WrkStnDate
			, Substring(InvcNum + ' / ' + @SalesTaxDescr + ' / ' + TaxLocID, 1, 30), 'AR', CustID, DistCode, LiabilityAcct 
			, CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END
			, CASE WHEN SUM(TaxAmount) < 0 THEN Abs(SUM(TaxAmount)) ELSE 0 END
			, FiscalYear, TransID, InvcNum, 0
			, @CurrBase, 1.0
			, CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END
			, CASE WHEN SUM(TaxAmount) < 0 THEN Abs(SUM(TaxAmount)) ELSE 0 END
		FROM #zzTax 
		GROUP BY TransId, CustID, DistCode, InvcDate, InvcNum, FiscalYear, GlPeriod, TaxLocID, LiabilityAcct
		HAVING SUM(TaxAmount) <> 0

	--Freight Amount 
	INSERT #ArTransPostLogDtl    
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate
		, PostDate, Descr, SourceCode, Reference, DistCode, GlAcct
		, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT DISTINCT @PostRun, TransId, GlPeriod, 100000, 102, Sign(TransType) * -1 * Freight
		, InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @FreightDescr, 1, 30)
		, 'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctFreight
		, CASE WHEN Sign(TransType) * -1 * Freight > 0
			THEN ABS(Freight) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * Freight < 0
			THEN ABS(Freight) ELSE 0 END
		, FiscalYear, TransID, InvcNum, 0
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * -1 * Freight > 0   
			THEN ABS(Freight) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * Freight < 0
			THEN ABS(Freight) ELSE 0 END
	FROM #Temp1
	WHERE Freight<>0 AND Freight IS NOT NULL

	--Misc Amount 
	INSERT #ArTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT DISTINCT @PostRun, TransId, GlPeriod, 100000, 103, Sign(TransType) * -1 * Misc,
			InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @MiscDescr, 1, 30),
			'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctMisc,
			CASE WHEN Sign(TransType) * -1 * Misc > 0
					THEN ABS(Misc) ELSE 0 END,
			CASE WHEN Sign(TransType) * -1 * Misc < 0
					THEN ABS(Misc) ELSE 0 END,
			FiscalYear, TransId, InvcNum, 0,
		@CurrBase, 1.0,
		CASE WHEN Sign(TransType) * -1 * Misc > 0    
					THEN ABS(Misc) ELSE 0 END,
			CASE WHEN Sign(TransType) * -1 * Misc < 0
					THEN ABS(Misc) ELSE 0 END
	FROM #Temp1
	WHERE Misc<>0 AND Misc IS NOT NULL


	--AR entry    
	INSERT #ArTransPostLogDtl        
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT DISTINCT @PostRun, TransId, GlPeriod, 100000, 104, 
		CASE WHEN TransType = -1 AND OrgInvcExchRate <> 1.0 
			THEN ROUND(InvcTotFgn / OrgInvcExchRate, @PrecCurr) ELSE InvcTot END,
		InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @ARDescr, 1, 30),
			'AR', CustId, #Temp1.DistCode, #Temp1.GLAcctReceivables,
 		CASE WHEN InvcTot > 0 THEN ABS(InvcTot) ELSE 0 END,
		CASE WHEN InvcTot < 0 THEN ABS(InvcTot) ELSE 0 END,
			FiscalYear, TransID, InvcNum, 0,
		CurrencyId, CASE WHEN CurrencyId = @CurrBase THEN 1.0 ELSE ExchRate END,
		CASE WHEN CurrencyId <> @CurrBase 
			THEN CASE WHEN InvcTotFgn > 0 THEN InvcTotFgn ELSE 0 END 
			ELSE CASE WHEN InvcTot > 0 THEN InvcTot ELSE 0 END
		END,
		CASE WHEN CurrencyId <> @CurrBase 
			THEN CASE WHEN InvcTotFgn < 0 THEN ABS(InvcTotFgn)ELSE 0 END 
			ELSE CASE WHEN InvcTot < 0 THEN ABS(InvcTot) ELSE 0 END 
		END 
	FROM #Temp1 WHERE InvcTot <> 0

	IF @MCYN = 1
	BEGIN
		--process gains/losses when MC is enabled
		Declare @GlDescr nvarchar(30)           
		SET @GlDescr = 'Gains/Losses' 

		--capture acct info for each distribution code to simplify processing
		CREATE TABLE [#DistCodeAccts]
		(
			[DistCode] [nvarchar] (6),
			[GLAcctReceivables] [pGlAcct],
			[BaseAcct] [bit],
			[CurrencyId] [pCurrency]
		)

		INSERT INTO #DistCodeAccts (DistCode, GLAcctReceivables, BaseAcct, CurrencyId)
		SELECT d.DistCode, d.GLAcctReceivables
			, CASE WHEN ISNULL(g.CurrencyId, @CurrBase) = @CurrBase THEN 1 ELSE 0 END
			, ISNULL(g.CurrencyId, @CurrBase)
			FROM dbo.tblArDistCode d 
			LEFT JOIN dbo.tblGlAcctHdr g on d.GLAcctReceivables = g.AcctId


		CREATE TABLE [#tmpArTransPostGainLoss] 
		(
			[PostRun] pPostRun NULL ,
			[Counter] [int] IDENTITY (1, 1) NOT NULL ,
			[GlPeriod] [smallint] NULL ,
			[TransId] pTransId NULL ,
			[EntryNum] [int] NULL ,
			[Grouping] [smallint] NULL ,
			[Amount] [pDecimal],
			[TransDate] [datetime] NULL ,
			[DistCode] [nvarchar] (6) NULL ,
			[GlAcct] [nvarchar] (40) NULL ,
			[DR] [pDecimal] NULL,
			[CR] [pDecimal] NULL,
			[DRFgn] [pDecimal] NULL,
			[CRFgn] [pDecimal] NULL,
			[Year] [smallint] NULL ,
			[LinkID] [nvarchar] (15) NULL ,
			[LinkIDSub] [nvarchar] (15) NULL ,
			[LinkIDSubLine] [int] NULL,
			[TransCurrencyId] [pCurrency] NULL,  --currencyid for trans/pmt
			[ExchRate] pDecimal NULL
		)

		--Gain/Loss for credit memo's (flip sign on CalcGainLoss to offset transtype = -1)
		--Use the realized accounts for Gain/Loss amounts
		INSERT #tmpArTransPostGainLoss
			(PostRun,TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, h.TransID, h.GlPeriod, 100000, 300, -h.CalcGainLoss, h.InvcDate,
			h.DistCode, Case When -h.CalcGainLoss > 0 THEN t.RealGainAcct ELSE t.RealLossAcct END GlAcctGainLoss
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, h.FiscalYear, h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), -6, @CurrBase, 1.0
		FROM dbo.tblArTransHeader h 
		LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		WHERE h.TransType = -1 And h.CalcGainLoss <> 0 

		--Gain/Loss for credit memo's - AR Offset  (flip sign on CalcGainLoss to offset transtype = -1) 
		--Don't populate the Fgn Debit/Credit columns for the gain/loss amounts 
		--	when the receivables account is foreign
		INSERT #tmpArTransPostGainLoss
			(PostRun,TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, h.TransID, h.GlPeriod, 100000, 300, -h.CalcGainLoss, h.InvcDate
			, h.DistCode, dc.GLAcctReceivables
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN dc.BaseAcct = 1 THEN CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END ELSE 0 END 
			, CASE WHEN dc.BaseAcct = 1 THEN CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END ELSE 0 END 
			, h.FiscalYear, h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), -6, @CurrBase, 1.0
		FROM dbo.tblArTransHeader h 
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		LEFT JOIN #DistCodeAccts dc ON h.DistCode = dc.DistCode
		WHERE h.TransType = -1 And h.CalcGainLoss <> 0 

		--conditionally include Gain/Loss Detail or Summary in the post logs
		IF @PostGainLossDtl = 1 
		BEGIN
			INSERT #ArTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
					@WrkStnDate, @GlDescr, 'G0', 'AR Gain/Loss', DistCode, GlAcct,
					DR, CR, [Year], LinkID, LinkIDSub, LinkIDSubLine,
					TransCurrencyId, ExchRate, DRFgn, CRFgn
				FROM #tmpArTransPostGainLoss
		END
		ELSE
		BEGIN
			INSERT #ArTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DR, CR, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, 100000, GlPeriod, 100000, 300, Sum(Amount), @WrkStnDate
					, @WrkStnDate, @GlDescr, 'G0', 'AR Gain/Loss', DistCode, GlAcct
					, [Year], NULL, NULL, -6
					, TransCurrencyId, ExchRate
					, Case When Sum(DR - CR) > 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DR - CR) <= 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) > 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) <= 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
				FROM #tmpArTransPostGainLoss 
				GROUP BY PostRun, TransCurrencyID, ExchRate, [Year], [GlPeriod], DistCode, GlAcct
		END
	END


	--populate the GL Log table
	IF (@ArGlDetailYn = 0)
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, Sum(Amount), 'AR'
			, CASE WHEN [Grouping] = 10 THEN @SalesDescr
				WHEN [Grouping] = 11 THEN @InventoryDescr
				WHEN [Grouping] = 12 THEN @COGSDescr
				WHEN [Grouping] = 101 THEN @SalesTaxDescr
				WHEN [Grouping] = 102 THEN @FreightDescr
				WHEN [Grouping] = 103 THEN @MiscDescr
				WHEN [Grouping] = 104 THEN @ARDescr
				ELSE @UnknownDescr END
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS [DebitAmount]
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END AS [CreditAmount]
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS [DebitAmountFgn]
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END AS [CreditAmountFgn]
			, 'AR', @WrkStnDate, @WrkStnDate, @CurrBase, 1.0, @CompId
		FROM #ArTransPostLogDtl 
		GROUP BY PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAcct 
	ELSE
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId
			, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, (DebitAmtFgn + CreditAmtFgn) AmountFgn
			, Reference, Descr
			, Cast(DR as decimal(28, 10)) DebitAmount
			, Cast(CR as decimal(28, 10)) CreditAmount
			, DebitAmtFgn, CreditAmtFgn 
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, @CompId
			, LinkID, LinkIDSub, LinkIDSubLine
			FROM #ArTransPostLogDtl 


	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod]
		, [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
		, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])
	SELECT FiscalYear, GlPeriod
		, SUM(SIGN(TransType)*(TaxSubtotal+NonTaxSubtotal+SalesTax+TaxAmtAdj+Freight+Misc + CalcGainLoss))
		, 0, 0
		, CurrencyId
		, SUM(SIGN(TransType)*(TaxSubtotalFgn+NonTaxSubtotalFgn+SalesTaxFgn+TaxAmtAdjFgn+FreightFgn+MiscFgn))
		, 0, 0
	FROM dbo.tblArTransHeader h
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	GROUP BY FiscalYear, GlPeriod, CurrencyId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_BuildLog_proc';


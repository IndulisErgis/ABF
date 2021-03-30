
CREATE PROCEDURE dbo.trav_SoTransPost_BuildLog_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE	@PostRun pPostRun
	, @MCYn bit
	, @ArGlYn bit
	, @ArInYn bit
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
	, @ReturnDirectToStock bit

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @ArInYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArInYn'
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
	SELECT @ReturnDirectToStock = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ReturnDirectToStock'

	IF @PostRun IS NULL OR @MCYn IS NULL 
		OR @ArGlYn IS NULL OR @ArInYn IS NULL OR @ArGlDetailYn IS NULL 
		OR @PostGainLossDtl IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL 
		OR @WrkStnDate IS NULL 
		OR @SalesDescr IS NULL OR @InventoryDescr IS NULL OR @COGSDescr IS NULL OR @SalesTaxDescr IS NULL 
		OR @FreightDescr IS NULL OR @MiscDescr IS NULL OR @ARDescr IS NULL OR @UnknownDescr IS NULL
		OR @ReturnDirectToStock IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #SoTransPostLogDtl 
	(
		[Counter] int Not Null Identity(1, 1), 
		[PostRun] pPostRun Not Null, 
		[TransId] pTransId Null, 
		[EntryNum] int Null, 
		[Grouping] smallint Null, 
		[Amount] pDecimal Not Null, 
		[TransDate] datetime Null, 
		[PostDate] datetime Null, 
		[Descr] nvarchar(255) Null, 
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
	
	CREATE TABLE #TempDtl 
	(
		TransId pTransId NOT NULL, 
		EntryNum int NOT NULL, 
		FiscalYear smallint NULL, 
		GLPeriod smallint NULL, 
		TransType smallint NULL, 
		CustId pCustID NULL, 
		ExchRate pDecimal NULL, 
		InvcNum pInvoiceNum NULL, 
		InvcDate datetime NULL, 
		DistCode pDistCode NULL, 
		Descr nvarchar (255) NULL, 
		GLAcctSales pGlAcct NULL, 
		GLAcctCOGS pGlAcct NULL, 
		GLAcctInv pGlAcct NULL, 
		QtyShipSell pDecimal NULL, 
		UnitPriceSell pDecimal NULL, 
		UnitCostSell pDecimal NULL, 
		ExtPrice pDecimal NULL, 
		ExtCost pDecimal NULL, 
		PriceExtFgn pDecimal NULL, 
		CostExtFgn pDecimal NULL, 
		ItemId pItemID NULL, 
		GrpID int NULL, 
		Kit bit NULL, 
		ItemType tinyint NULL, 
		DropShipYn bit NOT NULL DEFAULT (0)
	)

	CREATE TABLE #TempHdr 
	(
		TransId pTransId NOT NULL, 
		FiscalYear smallint NULL, 
		GLPeriod smallint NULL, 
		TransType smallint NULL, 
		CustId pCustID NULL, 
		CurrencyId pCurrency NULL, 
		ExchRate pDecimal NULL, 
		InvcNum pInvoiceNum NULL, 
		InvcDate datetime NULL, 
		TaxableSales pDecimal NULL, 
		TaxableSalesFgn pDecimal NULL, 
		NonTaxableSales pDecimal NULL, 
		NonTaxableSalesFgn pDecimal NULL, 
		SalesTax pDecimal NULL, 
		SalesTaxFgn pDecimal NULL, 
		Freight pDecimal NULL, 
		FreightFgn pDecimal NULL, 
		Misc pDecimal NULL, 
		MiscFgn pDecimal NULL, 
		TotCost pDecimal NULL, 
		DistCode pDistCode NULL, 
		BatchId pBatchID NULL, 
		GLAcctReceivables pGlAcct NULL, 
		GLAcctFreight pGlAcct NULL, 
		GLAcctMisc pGlAcct NULL, 
		TaxAmtAdj pDecimal NULL, 
		TaxAmtAdjFgn pDecimal NULL, 
		TaxLocAdj pTaxLoc NULL, 
		TaxClassAdj tinyint NULL, 
		TaxAdj tinyint NULL, 
		OrgInvcExchRate pDecimal NULL DEFAULT (1), 
		InvcTotFgn pDecimal NULL, 
		InvcTot pDecimal NULL
	)


	-- get detail accounts
	INSERT INTO #TempDtl (TransId, EntryNum, FiscalYear, GLPeriod, TransType, CustId, ExchRate, InvcNum, InvcDate
		, DistCode, Descr, GLAcctSales, GLAcctCOGS, GLAcctInv, QtyShipSell, UnitPriceSell, UnitCostSell
		, ExtPrice, ExtCost, PriceExtFgn, CostExtFgn, ItemId, GrpID, Kit, ItemType, DropShipYn) 
	SELECT th.TransId, td.EntryNum, th.FiscalYear, th.GLPeriod, th.TransType, th.CustId, th.ExchRate
		, l.DefaultInvoiceNumber, th.InvcDate
		, th.DistCode, td.Descr, td.GLAcctSales, td.GLAcctCOGS, td.GLAcctInv, td.QtyShipSell, td.UnitPriceSell, td.UnitCostSell
		, td.PriceExt, td.CostExt, td.PriceExtFgn, td.CostExtFgn, td.ItemId, td.GrpID, td.Kit, td.ItemType
		, ISNULL(k.DropShipYn, 0) DropShipYn 
	FROM dbo.tblSoTransHeader th 
	INNER JOIN #PostTransList l ON th.TransId = l.TransId
	INNER JOIN dbo.tblSoTransDetail td ON th.TransId = td.TransID 
	LEFT JOIN dbo.tblSmTransLink k ON td.LinkSeqNum = k.SeqNum -- capture the drop ship flag via trans link 
	WHERE td.[Status] = 0  -- open line items
	ORDER BY th.TransId, th.FiscalYear, th.GLPeriod, td.EntryNum

	-- get header accounts
	INSERT INTO #TempHdr (TransId, FiscalYear, GLPeriod, TransType, CustId, CurrencyId, ExchRate, InvcNum, InvcDate
		, TaxableSales, TaxableSalesFgn, NonTaxableSales, NonTaxableSalesFgn, SalesTax, SalesTaxFgn
		, Freight, FreightFgn, Misc, MiscFgn, TotCost, DistCode, BatchId
		, GLAcctReceivables, GLAcctFreight, GLAcctMisc
		, TaxAmtAdj, TaxAmtAdjFgn, TaxLocAdj, TaxClassAdj, TaxAdj, OrgInvcExchRate, InvcTotFgn, InvcTot) 
	SELECT th.TransId, th.FiscalYear, th.GLPeriod, th.TransType, th.CustId, th.CurrencyId, th.ExchRate
		, l.DefaultInvoiceNumber, th.InvcDate
		, th.TaxableSales, th.TaxableSalesFgn, th.NonTaxableSales, th.NonTaxableSalesFgn, th.SalesTax, th.SalesTaxFgn
		, th.Freight, th.FreightFgn, th.Misc, th.MiscFgn, th.TotCost, th.DistCode, th.BatchId
		, dc.GLAcctReceivables, dc.GLAcctFreight, dc.GLAcctMisc
		, th.TaxAmtAdj, th.TaxAmtAdjFgn, th.TaxLocAdj, th.TaxClassAdj, th.TaxAdj, th.OrgInvcExchRate
		, SIGN(TransType) * (TaxableSalesFgn + NonTaxableSalesFgn + SalesTaxFgn + TaxAmtAdjFgn + FreightFgn + MiscFgn) AS InvcTotFgn
		, SIGN(TransType) * (TaxableSales + NonTaxableSales + SalesTax + TaxAmtAdj + Freight + Misc) AS InvcTot 
	FROM dbo.tblSoTransHeader th 
	INNER JOIN #PostTransList l ON th.TransId = l.TransId
	INNER JOIN dbo.tblArDistCode dc ON dc.DistCode = th.DistCode 
	ORDER BY th.TransId, th.FiscalYear, th.GLPeriod


	--retrieve currency from gl receivables account when mc is enabled
	IF @ArGlYn = 1 AND @MCYN = 1
	BEGIN
		UPDATE #TempHdr SET CurrencyId = g.CurrencyID 
		FROM #TempHdr h INNER JOIN dbo.tblGlAcctHdr g ON h.GLAcctReceivables = g.AcctId
	END

	-- Line Sales -- regular items or kits -- post to base
	INSERT INTO #SoTransPostLogDtl
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, GlPeriod, TransId, EntryNum, 10
		, Convert(Decimal(28,10), Sign(TransType)) * -1 * (ExtPrice)
		, InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(ItemId, ''), 1, 30) END 
		, 'SO', CustId, DistCode, GLAcctSales
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
	FROM #TempDtl t
	WHERE EntryNum IS NOT NULL AND (ExtPrice) <> 0 AND GrpId IS NULL

	/** Inventory Sales -- regular or kit components**/
	-- for linkidsubline use kits entrynum for components
	-- post to base
	-- skip Inventory & COGS journal entry for Credits of inventoried items when not returning qty direct to stock
	-- skip Inventory & COGS journal entry for Drop Shipped line items
	INSERT #SoTransPostLogDtl
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)    
	SELECT @PostRun, GlPeriod, TransId, EntryNum, 11
		, Sign(TransType) * -1 * (ExtCost)
		, InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(ItemId, ''), 1, 30) END 
		, 'SO', CustId, DistCode, GLAcctInv
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) > 0
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
		, FiscalYear, TransID, InvcNum, COALESCE(GrpID, EntryNum)
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) > 0     
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
	FROM #TempDtl
	WHERE EntryNum IS NOT NULL AND (ExtCost) <> 0
		AND (Kit = 0 OR GrpID IS NOT NULL)
		AND (@ReturnDirectToStock = 1 OR TransType >= 0 OR (ItemType NOT IN (1, 2))) -- skip for credits
		AND (DropShipYn = 0) -- skip for drop shipped


	/** COGS -- regular or kit components : post to base**/
	-- for linkidsubline use kits entrynum for components
	-- skip Inventory and COGS journal entry for Credits of inventoried items when not returning qty direct to stock
	-- skip Inventory & COGS journal entry for Drop Shipped line items
	INSERT #SoTransPostLogDtl
		(PostRun, FiscalPeriod, TransId, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, GlPeriod, TransId, EntryNum, 12, 
		Sign(TransType) * (ExtCost), InvcDate, @WrkStnDate
		, CASE WHEN @ArInYn = 1 AND Descr IS NOT NULL 
			THEN substring(InvcNum + ' / ' + Descr, 1, 30)
			ELSE substring(InvcNum + ' / ' + isnull(ItemId, ''), 1, 30) END 
		, 'SO', CustId, DistCode, GLAcctCOGS
		, CASE WHEN Sign(TransType) * (ExtCost) > 0
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
		, FiscalYear, TransID, InvcNum, COALESCE(GrpID, EntryNum)
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * (ExtCost) > 0   
			THEN ABS(ExtCost) ELSE 0 END
		, CASE WHEN Sign(TransType) * (ExtCost) < 0
			THEN ABS(ExtCost) ELSE 0 END
	FROM #TempDtl
	WHERE EntryNum IS NOT NULL AND (ExtCost) <> 0
		AND (Kit = 0 OR GrpID IS NOT NULL)
		AND (@ReturnDirectToStock = 1 OR TransType >= 0 OR (ItemType NOT IN (1, 2))) -- skip for credits
		AND (DropShipYn = 0) -- skip for drop shipped


	--Tax Locations
	Create Table #zzTax
	(
		TransId pTransId, 
		InvcNum pInvoiceNum Null, 
		FiscalYear smallint, 
		GLPeriod smallint, 
		TaxAmount pDecimal Null,
		TaxAmountFgn pDecimal Null, --PET:227962
		InvcDate datetime,
		TaxLocID pTaxLoc Null,
		CustID pCustId Null, 
		DistCode pDistCode Null, 
		LiabilityAcct pGlAcct Null,
		CurrencyId pCurrency Null, --PET:227962
		ExchRate pDecimal Null
	)
                        
	--tax detail (PET:227962 - include TaxAmtFgn, CurrencyId)
	INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, GLPeriod, TaxAmount, TaxAmountFgn 
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, CurrencyId, ExchRate)
		SELECT h.TransId, l.DefaultInvoiceNumber, h.FiscalYear, h.GLPeriod
			, Sign(h.TransType) * -1 * TaxAmt
			, Sign(h.TransType) * -1 * TaxAmtFgn
			, h.InvcDate, t.TaxLocID, h.CustID, h.DistCode, t.LiabilityAcct, h.CurrencyId, h.ExchRate
		FROM #TempHdr h
		INNER JOIN dbo.tblSoTransTax t ON h.TransId = t.TransId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE t.TaxAmt <> 0
			
	--tax adjustments (PET:227962 - include TaxAmtAdjFgn, CurrencyId)
	INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, GLPeriod, TaxAmount, TaxAmountFgn
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, CurrencyId, ExchRate)
		SELECT h.TransId, l.DefaultInvoiceNumber, h.FiscalYear, h.GLPeriod
			, Sign(h.TransType) * -1 * TaxAmtAdj
			, Sign(h.TransType) * -1 * TaxAmtAdjFgn
			, h.InvcDate, h.TaxLocAdj, h.CustID, h.DistCode, t.GlAcct, h.CurrencyId, h.ExchRate
		FROM #TempHdr h
		LEFT JOIN dbo.tblSmTaxLoc t on h.TaxLocAdj = t.TaxLocId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE TaxAmtAdj <> 0

	--PET:227962 
	--retrieve currency from gl tax accounts when mc is enabled
	IF @ArGlYn = 1 AND @MCYN = 1
	BEGIN
		UPDATE #zzTax SET CurrencyId = g.CurrencyID 
		FROM #zzTax t INNER JOIN dbo.tblGlAcctHdr g ON t.LiabilityAcct = g.AcctId
		
		--check for mismatched currencies (between the tax liability account and the transaction)
		--NOTE:this test should be implemented differently when the multi-currency enhancements are done
		IF EXISTS(SELECT * FROM #zzTax t INNER JOIN dbo.tblSoTransHeader h (nolock) ON t.TransId = h.TransId WHERE t.CurrencyId <> @CurrBase AND t.CurrencyId <> h.CurrencyId)
		BEGIN
			DECLARE @MismatchTranId AS pTransId
			SELECT TOP 1 @MismatchTranId = t.TransId FROM #zzTax t INNER JOIN dbo.tblSoTransHeader h (nolock) ON t.TransId = h.TransId WHERE t.CurrencyId <> @CurrBase AND t.CurrencyId <> h.CurrencyId
			RAISERROR('Mismatched currencies exist. (TransID: %s)', 16, 1, @MismatchTranId)
		END
	END

	--PET:227962 - Include TaxAmountFgn
	INSERT #SoTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, TransID, GlPeriod, 100000,101
			, SUM(TaxAmount)
			, InvcDate, @WrkStnDate
			, Substring(InvcNum + ' / ' + @SalesTaxDescr + ' / ' + TaxLocID, 1, 30), 'SO', CustID, DistCode, LiabilityAcct 
			, CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END
			, CASE WHEN SUM(TaxAmount) < 0 THEN Abs(SUM(TaxAmount)) ELSE 0 END
			, FiscalYear, TransID, InvcNum, 0
			, CurrencyId, CASE WHEN CurrencyId = @CurrBase THEN 1.0 ELSE ExchRate END
			, CASE WHEN CurrencyId <> @CurrBase 
				THEN CASE WHEN SUM(TaxAmountFgn) > 0 THEN SUM(TaxAmountFgn) ELSE 0 END
				ELSE CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END
				END
			, CASE WHEN CurrencyId <> @CurrBase 
				THEN CASE WHEN SUM(TaxAmountFgn) < 0 THEN Abs(SUM(TaxAmountFgn)) ELSE 0 END
				ELSE CASE WHEN SUM(TaxAmount) < 0 THEN Abs(SUM(TaxAmount)) ELSE 0 END
				END
		FROM #zzTax 
		GROUP BY TransId, CustID, DistCode, InvcDate, InvcNum, FiscalYear, GlPeriod, TaxLocID, LiabilityAcct, CurrencyId, ExchRate
		HAVING SUM(TaxAmount) <> 0

	--Freight Amount 
	INSERT #SoTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate
		, PostDate, Descr, SourceCode, Reference, DistCode, GlAcct
		, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, TransId, GlPeriod, 100000, 102, Sign(TransType) * -1 * Freight
		, InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @FreightDescr, 1, 30)
		, 'SO', CustId, DistCode, GLAcctFreight
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
	FROM #TempHdr
	WHERE Freight<>0 AND Freight IS NOT NULL

	--Misc Amount 
	INSERT #SoTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, TransId, GlPeriod, 100000, 103, Sign(TransType) * -1 * Misc
		, InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @MiscDescr, 1, 30)
		, 'SO', CustId, DistCode, GLAcctMisc
		, CASE WHEN Sign(TransType) * -1 * Misc > 0
			THEN ABS(Misc) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * Misc < 0
			THEN ABS(Misc) ELSE 0 END
		, FiscalYear, TransID, InvcNum, 0
		, @CurrBase, 1.0
		, CASE WHEN Sign(TransType) * -1 * Misc > 0    
			THEN ABS(Misc) ELSE 0 END
		, CASE WHEN Sign(TransType) * -1 * Misc < 0
			THEN ABS(Misc) ELSE 0 END
	FROM #TempHdr
	WHERE Misc<>0 AND Misc IS NOT NULL


	-- AR Entry  post to base or foreign account
	INSERT #SoTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)   
	SELECT @PostRun, TransId, GlPeriod, 100000, 104
		, CASE WHEN TransType = -1 AND OrgInvcExchRate <> 1.0 
			THEN ROUND(InvcTotFgn / OrgInvcExchRate, @PrecCurr) ELSE InvcTot END
		, InvcDate, @WrkStnDate, SubString(InvcNum + ' / ' + @ARDescr, 1, 30)
		, 'SO', CustId, DistCode, GLAcctReceivables
 		, CASE WHEN InvcTot > 0 THEN ABS(InvcTot) ELSE 0 END
		, CASE WHEN InvcTot < 0 THEN ABS(InvcTot) ELSE 0 END
		, FiscalYear, TransID, InvcNum, 0
		, CurrencyId, CASE WHEN CurrencyId = @CurrBase THEN 1.0 ELSE ExchRate END
		, CASE WHEN CurrencyId <> @CurrBase 
			THEN CASE WHEN InvcTotFgn > 0 THEN InvcTotFgn ELSE 0 END 
			ELSE CASE WHEN InvcTot > 0 THEN InvcTot ELSE 0 END
			END
		, CASE WHEN CurrencyId <> @CurrBase 
			THEN CASE WHEN InvcTotFgn < 0 THEN ABS(InvcTotFgn)ELSE 0 END 
			ELSE CASE WHEN InvcTot < 0 THEN ABS(InvcTot) ELSE 0 END 
			END 
	FROM #TempHdr WHERE InvcTot <> 0


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

		CREATE TABLE [#tmpSoTransPostGainLoss] 
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
		INSERT #tmpSoTransPostGainLoss
			(PostRun,TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, h.TransID, h.GlPeriod, 100000, 300, -h.CalcGainLoss, h.InvcDate,
			h.DistCode, Case When -h.CalcGainLoss > 0 THEN t.RealGainAcct ELSE t.RealLossAcct END GlAcctGainLoss
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, h.FiscalYear, NULL, l.DefaultInvoiceNumber, -6, @CurrBase, 1.0
		FROM dbo.tblSoTransHeader h 
		LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		WHERE h.TransType = -1 And h.CalcGainLoss <> 0 

		--Gain/Loss for credit memo's - AR Offset  (flip sign on CalcGainLoss to offset transtype = -1) 
		--Don't populate the Fgn Debit/Credit columns for the gain/loss amounts 
		--	when the receivables account is foreign
		INSERT #tmpSoTransPostGainLoss
			(PostRun,TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, h.TransID, h.GlPeriod, 100000, 300, -h.CalcGainLoss, h.InvcDate
			, h.DistCode, dc.GLAcctReceivables
			, CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END
			, CASE WHEN dc.BaseAcct = 1 THEN CASE WHEN -h.CalcGainLoss < 0 THEN 0 ELSE Abs(h.CalcGainLoss) END ELSE 0 END 
			, CASE WHEN dc.BaseAcct = 1 THEN CASE WHEN -h.CalcGainLoss > 0 THEN 0 ELSE Abs(h.CalcGainLoss) END ELSE 0 END 
			, h.FiscalYear, NULL, l.DefaultInvoiceNumber, -6, @CurrBase, 1.0
		FROM dbo.tblSoTransHeader h 
		INNER JOIN #PostTransList l on h.TransId = l.TransId
		LEFT JOIN #DistCodeAccts dc ON h.DistCode = dc.DistCode
		WHERE h.TransType = -1 And h.CalcGainLoss <> 0 

		--conditionally include Gain/Loss Detail or Summary in the post logs
		IF @PostGainLossDtl = 1 
		BEGIN
			INSERT #SoTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
					@WrkStnDate, @GlDescr, 'G0', 'SO Gain/Loss', DistCode, GlAcct,
					DR, CR, [Year], LinkID, LinkIDSub, LinkIDSubLine,
					TransCurrencyId, ExchRate, DRFgn, CRFgn
				FROM #tmpSoTransPostGainLoss
		END
		ELSE
		BEGIN
			INSERT #SoTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DR, CR, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, 100000, GlPeriod, 100000, 300, Sum(Amount), @WrkStnDate
					, @WrkStnDate, @GlDescr, 'G0', 'SO Gain/Loss', DistCode, GlAcct
					, [Year], NULL, NULL, -6
					, TransCurrencyId, ExchRate
					, Case When Sum(DR - CR) > 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DR - CR) <= 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) > 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) <= 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
				FROM #tmpSoTransPostGainLoss 
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
			, GlAcct, Sum(Amount), 'SO'
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
			, 'SO', @WrkStnDate, @WrkStnDate, @CurrBase, 1.0, @CompId
		FROM #SoTransPostLogDtl
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
			FROM #SoTransPostLogDtl


	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod]
		, [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
		, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])
	SELECT FiscalYear, GlPeriod
		, SUM(SIGN(TransType)*(TaxableSales + NonTaxableSales + SalesTax + TaxAmtAdj + Freight + Misc + CalcGainLoss))
		, 0, 0
		, CurrencyId
		, SUM(SIGN(TransType)*(TaxableSalesFgn + NonTaxableSalesFgn + SalesTaxFgn + TaxAmtAdjFgn + FreightFgn + MiscFgn))
		, 0, 0
	FROM dbo.tblSoTransHeader h
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	GROUP BY FiscalYear, GlPeriod, CurrencyId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_BuildLog_proc';


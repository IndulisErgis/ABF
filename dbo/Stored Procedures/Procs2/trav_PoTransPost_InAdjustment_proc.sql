
CREATE PROCEDURE dbo.trav_PoTransPost_InAdjustment_proc
AS
BEGIN TRY

	DECLARE @InCostingMethod smallint,@PrecCurr smallint, 
		@PostRun nvarchar (14),@WksDate datetime,@CurrBase pCurrency,@UseLandedCost bit,@CompId nvarchar(3), @PrecUCost smallint

	--Retrieve global values
	SELECT @UseLandedCost = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'UseLandedCost'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @InCostingMethod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'CostingMethod'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PrecUCost = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecUCost'

	IF @UseLandedCost IS NULL OR @CurrBase IS NULL OR @CompId IS NULL
		OR @PostRun IS NULL OR @WksDate IS NULL OR @InCostingMethod IS NULL OR @PrecCurr IS NULL OR @PrecUCost IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE [#tmpAdjustment] 
	(
		[InvcNum] pInvoiceNum NOT NULL, 
		[ItemId] [pItemID] NOT NULL, 
		[LocId] [pLocID] NOT NULL, 
		[AdjAmt] [pDecimal] NOT NULL, 
		[GlAcctCode] [pGLAcctCode] NOT NULL, 
		[FiscalYear] [smallint] NOT NULL, 
		[FiscalPeriod] [smallint] NOT NULL, 
		[TransDate] datetime NULL,
		[BatchId] pBatchId NOT NULL,
		[TransId] pTransId NOT NULL,
		[AdjType] tinyint NOT NULL
	)

	-- make IN COGS adjustment for PO invoices using the Average costing method
	IF @InCostingMethod = 2
	BEGIN
		INSERT INTO #tmpAdjustment (AdjType,InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
 		SELECT 1,i.InvoiceNum, d.ItemId, d.LocId, SUM(SIGN(h.TransType) * ROUND(ir.Qty * ( i.UnitCost - r.UnitCost), @PrecCurr))
			,l.GlAcctCode, o.FiscalYear, o.GlPeriod, o.InvcDate,h.BatchId,h.TransId
		FROM #PostTransList  b INNER JOIN dbo.tblPoTransHeader h ON b.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransId 
			INNER JOIN dbo.tblPoTransInvoice i ON b.TransId = i.TransId AND d.EntryNum = i.EntryNum 
			INNER JOIN dbo.tblPoTransInvoiceTot o ON i.TransId = o.TransId AND i.InvoiceNum = o.InvcNum
			INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON i.InvoiceID = ir.InvoiceID 
			INNER JOIN dbo.tblPoTransLotRcpt r ON r.ReceiptID = ir.ReceiptID 
			INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		WHERE d.InItemYn = 1 AND ISNULL(d.ProjectDetailId,0) = 0 
			AND d.ItemType = 1 AND i.Status = 0 AND (h.DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0)
		GROUP BY h.TransId, d.EntryNum, d.ItemId, d.LocId, l.GlAcctCode, i.InvoiceNum, o.FiscalYear, o.GlPeriod, o.InvcDate, h.BatchId
		HAVING SUM(SIGN(h.TransType) * ROUND(ir.Qty * ( i.UnitCost - r.UnitCost), @PrecCurr)) <> 0
	END

	-- create IN Gl Adjustment PPV entries
	IF @UseLandedCost = 1 
	BEGIN
		-- Invoice (Regular, Lotted)
		INSERT INTO #tmpAdjustment (AdjType,InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
		SELECT 2, v.InvoiceNum, d.ItemId, d.LocId, v.ExtCost + ISNULL(n.LandedCostAmt, 0) - ROUND(ROUND((v.ExtCost + ISNULL(n.LandedCostAmt, 0)) / v.Qty, @PrecUCost) * v.Qty, @PrecCurr)
			, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvcDate,h.BatchId,h.TransId
		FROM #PostTransList c INNER JOIN dbo.tblPoTransHeader h ON c.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
			INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID 
			INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
			INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
			INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum AND t.InvcNum = v.InvoiceNum 
			LEFT JOIN (SELECT i.InvoiceID, SUM(ROUND(l.LandedCostAmt * i.Qty / r.QtyFilled, @PrecCurr)) AS LandedCostAmt
				FROM dbo.tblPoTransLotRcpt r INNER JOIN (SELECT ReceiptID, SUM(PostedAmount) LandedCostAmt FROM dbo.tblPoTransReceiptLandedCost GROUP BY ReceiptID) l ON r.ReceiptID = l.ReceiptID 
					INNER JOIN dbo.tblPoTransInvc_Rcpt i ON r.ReceiptID = i.ReceiptID
				GROUP BY i.InvoiceID) n ON v.InvoiceID = n.InvoiceID
		WHERE h.TransType > 0 AND v.Status = 0 AND (h.DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0) --Exclude drop ship
			AND v.ExtCost + ISNULL(n.LandedCostAmt, 0) - ROUND(ROUND((v.ExtCost + ISNULL(n.LandedCostAmt, 0)) / v.Qty, @PrecUCost) * v.Qty, @PrecCurr) <> 0 
			AND i.ItemType <> 3 --Exclude service item
			AND ISNULL(d.ProjectDetailId,0) = 0 --Exclude project item
	END
	ELSE
	BEGIN
		-- Invoice (Regular, Lotted)
		INSERT INTO #tmpAdjustment (AdjType,InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
		SELECT 2, v.InvoiceNum, d.ItemId, d.LocId, v.ExtCost - ROUND(v.UnitCost * v.Qty, @PrecCurr)
			, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvcDate,h.BatchId,h.TransId
		FROM #PostTransList  c INNER JOIN dbo.tblPoTransHeader h ON c.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
			INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID 
			INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
			INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
			INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum AND t.InvcNum = v.InvoiceNum 
		WHERE h.TransType > 0 AND v.Status = 0 AND (h.DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0) --Exclude drop ship
			AND v.ExtCost - ROUND(v.UnitCost * v.Qty, @PrecCurr) <> 0 AND i.ItemType <> 3 --Exclude service item 
			AND ISNULL(d.ProjectDetailId,0) = 0 --Exclude project item
	END

	--Ser item should not have rounding issue related to landed cost since landed cost is calculated per ser number.
	--No landed cost for debit memo
	-- Invoice, Debit Memo (Serialized)
	INSERT INTO #tmpAdjustment (AdjType,InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT 2, v.InvoiceNum, d.ItemId, d.LocId, SIGN(MIN(h.TransType)) * (MIN(v.ExtCost) - ROUND(SUM(s.InvcUnitCost), @PrecCurr))
		, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvcDate,h.BatchId,h.TransId
	FROM #PostTransList  c INNER JOIN dbo.tblPoTransHeader h ON c.TransId = h.TransId  
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
		INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum AND t.InvcNum = v.InvoiceNum 
		INNER JOIN dbo.tblPoTransSer s ON d.TransID = s.TransID AND d.EntryNum = s.EntryNum AND v.InvoiceNum  = s.InvcNum 
	WHERE v.Status = 0 AND ISNULL(d.ProjectDetailId,0) = 0 --Exclude project item
	GROUP BY h.TransId, d.EntryNum, d.ItemId, d.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.GlPeriod, v.InvoiceNum, h.BatchId, t.InvcDate
	HAVING MIN(v.ExtCost) <> ROUND(SUM(s.InvcUnitCost), @PrecCurr)

	-- Debit Memo (Regular, Lotted)
	INSERT INTO #tmpAdjustment (AdjType,InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT 2, v.InvoiceNum, d.ItemId, d.LocId, -1 * (MIN(v.ExtCost) - MIN(ROUND(v.Qty * v.UnitCost, @PrecCurr)))
		, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvcDate,h.BatchId,h.TransId
	FROM #PostTransList  c INNER JOIN dbo.tblPoTransHeader h ON c.TransId = h.TransId  
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
		INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		INNER JOIN dbo.tblInItem m ON l.ItemId = m.ItemId
		INNER JOIN dbo.tblPoTransInvoice v ON d.TransID = v.TransID AND d.EntryNum = v.EntryNum AND t.InvcNum = v.InvoiceNum 
		INNER JOIN dbo.tblPoTransInvc_Rcpt i ON v.InvoiceID = i.InvoiceID 
		INNER JOIN dbo.tblInQtyOnHand_Offset o ON i.QtySeqNum = o.SeqNum OR i.QtySeqNum = o.GrpID 
	WHERE h.TransType < 0 AND v.Status = 0 AND m.ItemType <> 3 --Exclude service item 
		AND ISNULL(d.ProjectDetailId,0) = 0 --Exclude project item
	GROUP BY h.TransId, d.EntryNum, d.ItemId, d.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.GlPeriod, v.InvoiceNum, h.BatchId, t.InvcDate
	HAVING MIN(v.ExtCost) <> MIN(ROUND(v.Qty * v.UnitCost, @PrecCurr))

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, CASE WHEN t.AdjType = 1 THEN 500 ELSE 501 END, 
		CASE WHEN t.AdjType = 1 THEN g.GLAcctCogsAdj ELSE g.GLAcctPurchPriceVar END, t.AdjAmt, 'PO',
		CASE WHEN t.AdjType = 1 THEN 'COGS Adjustment' ELSE 'Purchase Price Variance' END,
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		'PO', @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode
	
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, CASE WHEN t.AdjType = 1 THEN 500 ELSE 501 END, 
		g.GLAcctInvAdj, -t.AdjAmt, 'PO', 
		CASE WHEN t.AdjType = 1 THEN 'COGS Adjustment' ELSE 'Purchase Price Variance' END,
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		'PO', @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode

	INSERT INTO dbo.tblInHistDetail(HistSeqNum_Rcpt, ItemId, LocId, ItemType, LottedYN, TransType, SumYear, SumPeriod, 
		GLPeriod, AppId, BatchId, TransId, RefId, SrceID, TransDate, Uom, UomBase, ConvFactor, Qty, CostExt, CostStd, 
		PriceExt, CostUnit, PriceUnit, Source, Qty_Invc, CostExt_Invc, DropShipYn, LotNum)
	SELECT 0,t.ItemId, t.LocId, i.ItemType, i.LottedYN, CASE WHEN t.AdjType = 1 THEN 19 ELSE 20 END, t.FiscalYear, t.FiscalPeriod, t.FiscalPeriod, 'PO', t.BatchId, 
		t.TransId, t.InvcNum, CASE WHEN t.AdjType = 1 THEN 'COGS Adj' ELSE 'PPV' END, t.TransDate, i.UomBase, i.UomBase, 1, 0, t.AdjAmt, 0, 0, 0, 0, CASE WHEN t.AdjType = 1 THEN 200 ELSE 201 END, 0, 0, 0, NULL
	FROM #tmpAdjustment t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InAdjustment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InAdjustment_proc';


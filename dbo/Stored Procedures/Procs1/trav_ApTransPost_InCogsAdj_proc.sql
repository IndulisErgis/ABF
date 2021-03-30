
CREATE PROCEDURE dbo.trav_ApTransPost_InCogsAdj_proc
AS
BEGIN TRY
	/*Create PPV if extended cost is different than quantity multiply unit cost*/
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr smallint, @WksDate datetime,@CompId nvarchar(3)

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'

	IF @PrecCurr IS NULL OR @PostRun IS NULL OR @CurrBase IS NULL OR @WksDate IS NULL OR @CompId IS NULL
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
		[TransId] pTransId NOT NULL
	)
	
	-- Invoice
	--Regular Item
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT t.InvoiceNum, l.ItemId, l.LocId, (MIN(d.ExtCost) - MIN(ROUND(o.Qty * o.Cost, @PrecCurr))), 
		l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceDate, t.BatchId, t.TransId
	FROM  dbo.tblApTransHeader t INNER JOIN #PostTransList p ON t.TransId = p.TransId 
		INNER JOIN dbo.tblApTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblInItemLoc l ON d.PartId = l.ItemId AND d.WhseId = l.LocId 
		INNER JOIN dbo.tblInQtyOnHand o ON d.QtySeqNum = o.SeqNum 
	WHERE t.TransType > 0  AND d.InItemYN = 1
	GROUP BY t.BatchId, t.TransId, d.EntryNum, l.ItemId, l.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceNum , t.InvoiceDate
	HAVING (MIN(d.ExtCost) <> MIN(ROUND(o.Qty * o.Cost, @PrecCurr)))

	--Lot Item
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT t.InvoiceNum, l.ItemId, l.LocId, (MIN(d.ExtCost) - SUM(ROUND(o.Qty * o.Cost, @PrecCurr))), 
		l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceDate, t.BatchId, t.TransId
	FROM  dbo.tblApTransHeader t INNER JOIN #PostTransList p ON t.TransId = p.TransId 
		INNER JOIN dbo.tblApTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblInItemLoc l ON d.PartId = l.ItemId AND d.WhseId = l.LocId 
		INNER JOIN dbo.tblApTransLot n ON d.TransId = n.TransId AND d.EntryNum = n.EntryNum
		INNER JOIN dbo.tblInQtyOnHand o ON n.QtySeqNum = o.SeqNum 
	WHERE t.TransType > 0  AND d.InItemYN = 1
	GROUP BY t.BatchId, t.TransId, d.EntryNum, l.ItemId, l.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceNum , t.InvoiceDate
	HAVING (MIN(d.ExtCost) <> SUM(ROUND(o.Qty * o.Cost, @PrecCurr)))

	-- Serilized Item (Invoice and Debit Memo)
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT t.InvoiceNum, l.ItemId, l.LocId, SIGN(MIN(t.TransType)) * (MIN(d.ExtCost) - ROUND(SUM(s.CostUnit), @PrecCurr))
		, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceDate, t.BatchId, t.TransId
	FROM  dbo.tblApTransHeader t INNER JOIN #PostTransList p ON t.TransId = p.TransId 
		INNER JOIN dbo.tblApTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblApTransSer s ON d.TransID = s.TransID AND d.EntryNum = s.EntryNum 
		INNER JOIN dbo.tblInItemLoc l ON d.PartId = l.ItemId AND d.WhseId = l.LocId 
	WHERE  d.InItemYN = 1
	GROUP BY t.BatchId, t.TransId, d.EntryNum, l.ItemId, l.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.GlPeriod, t.InvoiceNum , t.InvoiceDate
	HAVING (MIN(d.ExtCost) <> ROUND(SUM(s.CostUnit), @PrecCurr))

	-- debit memo,
	--regular Item, Lot Item
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT t.InvoiceNum,l.ItemId, l.LocId, -1 * (MIN(d.ExtCost) - MIN(ROUND(d.Qty * d.UnitCost, @PrecCurr)))
		, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.InvoiceDate, t.BatchId, t.TransId
	FROM  dbo.tblApTransHeader t INNER JOIN #PostTransList p ON t.TransId = p.TransId 
		INNER JOIN dbo.tblApTransDetail d ON t.TransID = d.TransID 
		INNER JOIN dbo.tblInItemLoc l ON d.PartId = l.ItemId AND d.WhseId = l.LocId 
		INNER JOIN dbo.tblInQtyOnHand_Offset o ON d.QtySeqNum = o.SeqNum 
	WHERE  t.TransType < 0 AND  d.InItemYN = 1
	GROUP BY t.BatchId, t.TransId, d.EntryNum, l.ItemId, l.LocId, l.GlAcctCode, t.FiscalYear, t.GlPeriod, t.GlPeriod, t.InvoiceNum , t.InvoiceDate
	HAVING MIN(d.ExtCost) <> MIN(ROUND(d.Qty * d.UnitCost, @PrecCurr))

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, 501, g.GLAcctPurchPriceVar, t.AdjAmt, 'AP','Purchase Price Variance',
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		'AP', @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode
	
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, 501, g.GLAcctInvAdj, -t.AdjAmt, 'AP','Purchase Price Variance',
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		'AP', @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode

	INSERT INTO dbo.tblInHistDetail(HistSeqNum_Rcpt, ItemId, LocId, ItemType, LottedYN, TransType, SumYear, SumPeriod, 
		GLPeriod, AppId, BatchId, TransId, RefId, SrceID, TransDate, Uom, UomBase, ConvFactor, Qty, CostExt, CostStd, 
		PriceExt, CostUnit, PriceUnit, Source, Qty_Invc, CostExt_Invc, DropShipYn, LotNum)
	SELECT 0,t.ItemId, t.LocId, i.ItemType, i.LottedYN, 20, t.FiscalYear, t.FiscalPeriod, t.FiscalPeriod, 'AP', t.BatchId, 
		t.TransId, t.InvcNum, 'PPV', t.TransDate, i.UomBase, i.UomBase, 1, 0, t.AdjAmt, 0, 0, 0, 0, 201, 0, 0, 0, NULL
	FROM #tmpAdjustment t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_InCogsAdj_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_InCogsAdj_proc';


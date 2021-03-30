
CREATE PROCEDURE dbo.trav_InAdjustmentDeletedTransaction_proc 
@Source tinyint,
@AppId nchar(2),
@FiscalYear smallint,
@FiscalPeriod smallint,
@PostRun nvarchar (14),
@WksDate datetime,
@CurrBase pCurrency,
@CompId nvarchar(3)
AS
BEGIN TRY
	/* Create Inventory adjustments from deleted transactions which have posted adjustments. */
	/* Should be called only if Inventory costing method is FIFO/LIFO. */

	CREATE TABLE [#tmpAdjustment] 
	(
		[InvcNum] pInvoiceNum NULL, 
		[ItemId] [pItemID] NOT NULL, 
		[LocId] [pLocID] NOT NULL, 
		[AdjAmt] [pDecimal] NOT NULL, 
		[GlAcctCode] [pGLAcctCode] NOT NULL, 
		[FiscalYear] [smallint] NOT NULL, 
		[FiscalPeriod] [smallint] NOT NULL, 
		[TransDate] datetime NULL,
		[BatchId] pBatchId NULL,
		[TransId] pTransId NULL,
		[LotNum] pLotNum NULL
	)

	--Regular Item
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId, LotNum)
	SELECT o.LinkID, q.ItemId, q.LocId, -o.CostAdjPosted, l.GlAcctCode, @FiscalYear, @FiscalPeriod, o.EntryDate, NULL, o.LinkID, q.LotNum
	FROM dbo.tblInQtyOnHand_Offset o INNER JOIN dbo.tblInQtyOnHand q ON o.OnHandLink = q.SeqNum 
		INNER JOIN dbo.tblInItemLoc l ON q.ItemId = l.ItemId AND q.LocId = l.LocId
	WHERE o.Source = @Source AND o.DeletedYn = 1 AND o.CostAdjPosted <> 0

	UPDATE dbo.tblInQtyOnHand_Offset SET CostAdjPosted = 0
	WHERE Source = @Source AND DeletedYn = 1 AND CostAdjPosted <> 0
	
	--Serial Item
	INSERT INTO #tmpAdjustment (InvcNum,ItemId,LocId,AdjAmt,GlAcctCode,FiscalYear,FiscalPeriod,TransDate,BatchId,TransId)
	SELECT NULL, s.ItemId, s.LocId, -s.CostAdjPosted, l.GlAcctCode, @FiscalYear, @FiscalPeriod, @WksDate, NULL, NULL
	FROM dbo.tblInItemSer s INNER JOIN dbo.tblInItemLoc l ON s.ItemId = l.ItemId AND s.LocId = l.LocId
	WHERE s.Source = @Source AND s.SerNumStatus = 1 AND s.CostAdjPosted <> 0
	
	UPDATE dbo.tblInItemSer SET CostAdjPosted = 0
	WHERE Source = @Source AND SerNumStatus = 1 AND CostAdjPosted <> 0

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, 500, g.GLAcctCogsAdj, t.AdjAmt, 'COGS Adj',
		'Deleted transaction: ' + ISNULL(t.TransId,''),
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END, 
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END,
		@AppId, @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode
	
	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId)
	SELECT @PostRun, t.FiscalYear, t.FiscalPeriod, 500, g.GLAcctInvAdj, -t.AdjAmt, 'COGS Adj', 
		'Deleted transaction: ' + ISNULL(t.TransId,''),
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		CASE WHEN t.AdjAmt < 0 THEN ABS(t.AdjAmt) ELSE 0 END, 
		CASE WHEN t.AdjAmt > 0 THEN t.AdjAmt ELSE 0 END,
		@AppId, @WksDate, t.TransDate, @CurrBase , 1, @CompId, t.BatchId
	FROM #tmpAdjustment t LEFT JOIN dbo.tblInGlAcct g ON t.GlAcctCode = g.GlAcctCode

	INSERT INTO dbo.tblInHistDetail(HistSeqNum_Rcpt, ItemId, LocId, ItemType, LottedYN, TransType, SumYear, SumPeriod, 
		GLPeriod, AppId, BatchId, TransId, RefId, SrceID, TransDate, Uom, UomBase, ConvFactor, Qty, CostExt, CostStd, 
		PriceExt, CostUnit, PriceUnit, Source, Qty_Invc, CostExt_Invc, DropShipYn, LotNum)
	SELECT 0,t.ItemId, t.LocId, i.ItemType, i.LottedYN, 19, t.FiscalYear, t.FiscalPeriod, t.FiscalPeriod, @AppId, t.BatchId, 
		t.TransId, t.InvcNum, 'Adj/Del', t.TransDate, i.UomBase, i.UomBase, 1, 0, t.AdjAmt, 0, 0, 0, 0, 200, 0, 0, 0, t.LotNum
	FROM #tmpAdjustment t INNER JOIN dbo.tblInItem i ON t.ItemId = i.ItemId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InAdjustmentDeletedTransaction_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InAdjustmentDeletedTransaction_proc';


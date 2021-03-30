
CREATE PROCEDURE dbo.trav_InTransPost_GlLog_proc
AS
BEGIN TRY
	--PONewOrder = 11 
	--POGoodsRcvd = 12 
	--POInvoice = 14 
	--POMiscDebit = 15
	--SONewOrder = 21
	--SOVerifyOrder = 23
	--SOInvoice = 24
	--SOMiscCredit = 25
	--Increase = 31
	--Decrease = 32
	DECLARE @PrecCurr tinyint,@WrkStnDate datetime,
		@gInPostDtlGlYn bit, @PostRun pPostRun, @CurrBase pCurrency, @CompId nvarchar(3)

	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @gInPostDtlGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlGlYn'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'

	IF @gInPostDtlGlYn IS NULL OR @CompId IS NULL
		OR @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WrkStnDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #InTransPostLog (
		[ItemID] [dbo].[pItemID] NULL,
		[LocID] [dbo].[pLocID] NULL,
		[Period] [smallint] NULL,
		[TransDate] [datetime] NULL,
		[Descr] [nvarchar](30) NULL,
		[AcctID] [dbo].[pGlAcct] NULL,
		[DebitAmt] [dbo].[pDecimal] NULL,
		[CreditAmt] [dbo].[pDecimal] NULL,
		[LinkID] [nvarchar](15) NULL,
		[LinkIDSub] [nvarchar](15) NULL,
		[LinkIDSubLine] [int] NULL,
		[Year] [smallint] NULL,
		[TransId] [int] NULL,
		[Source] [int] NULL
	)

	--Cost
	--Credit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, [Source])
	SELECT t.ItemId,t.LocId,t.GlPeriod, t.TransDate, t.ItemId,
		CASE WHEN t.TransType IN (15, 23, 24) THEN g.GLAcctInv 
			WHEN t.TransType IN (12, 14, 31) THEN t.GlAcctOffset 
			WHEN t.TransType IN (32) THEN g.GLAcctInvAdj 
			WHEN t.TransType IN (25) THEN g.GlAcctCOGS 
		END,
		CASE WHEN t.CostUnitTrans * t.Qty > 0 THEN 0 ELSE ABS(ROUND(t.CostUnitTrans * t.Qty,@PrecCurr)) END,
		CASE WHEN t.CostUnitTrans * t.Qty > 0 THEN ROUND(t.CostUnitTrans * t.Qty,@PrecCurr) ELSE 0 END,
		t.SumYear, t.TransId, CASE t.TransType WHEN 12 THEN 11 WHEN 14 THEN 14 WHEN 15 THEN 72 WHEN 23 THEN 83 WHEN 24 THEN 84 WHEN 25 THEN 32 WHEN 31 THEN 15 WHEN 32 THEN 73 END
	FROM dbo.tblInTrans t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		 INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode 
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 
	WHERE t.TransType NOT IN (11,21) AND t.CostUnitTrans * t.Qty <> 0  

	--Debit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, [Source])
	SELECT t.ItemId,t.LocId,t.GlPeriod, t.TransDate, t.ItemId,
		CASE WHEN t.TransType IN (23, 24) THEN g.GlAcctCOGS 
			WHEN t.TransType IN (12, 14, 25) THEN g.GLAcctInv 
			WHEN t.TransType IN (15,32) THEN t.GlAcctOffset 
			WHEN t.TransType IN (31) THEN g.GLAcctInvAdj 

		END,
		CASE WHEN t.CostUnitTrans * t.Qty > 0 THEN ROUND(t.CostUnitTrans * t.Qty,@PrecCurr) ELSE 0 END,
		CASE WHEN t.CostUnitTrans * t.Qty > 0 THEN 0 ELSE ABS(ROUND(t.CostUnitTrans * t.Qty,@PrecCurr)) END,
		t.SumYear, t.TransId, CASE t.TransType WHEN 12 THEN 11 WHEN 14 THEN 14 WHEN 15 THEN 72 WHEN 23 THEN 83 WHEN 24 THEN 84 WHEN 25 THEN 32 WHEN 31 THEN 15 WHEN 32 THEN 73 END
	FROM dbo.tblInTrans t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		 INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode 
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 
	WHERE t.TransType NOT IN (11,21) AND t.CostUnitTrans * t.Qty <> 0

	--Price
	--Credit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, [Source])
	SELECT t.ItemId,t.LocId,t.GlPeriod, t.TransDate, t.ItemId,
		CASE WHEN t.TransType IN (23, 24) THEN g.GlAcctSales 
			WHEN t.TransType IN (25) THEN t.GlAcctOffset 
		END,
		CASE WHEN t.PriceUnit * t.Qty > 0 THEN 0 ELSE ABS(ROUND(t.PriceUnit * t.Qty,@PrecCurr)) END,
		CASE WHEN t.PriceUnit * t.Qty > 0 THEN ROUND(t.PriceUnit * t.Qty,@PrecCurr) ELSE 0 END,
		t.SumYear, t.TransId, CASE t.TransType WHEN 23 THEN 83 WHEN 24 THEN 84 WHEN 25 THEN 32 END
	FROM dbo.tblInTrans t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		 INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 		
	WHERE t.TransType IN (23,24,25) AND t.PriceUnit * t.Qty <> 0

	--Debit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, [Source])
	SELECT t.ItemId,t.LocId,t.GlPeriod, t.TransDate, t.ItemId,
		CASE WHEN t.TransType IN (23, 24) THEN t.GlAcctOffset 
			WHEN t.TransType IN (25) THEN g.GlAcctSales 
		END,
		CASE WHEN t.PriceUnit * t.Qty > 0 THEN ROUND(t.PriceUnit * t.Qty,@PrecCurr) ELSE 0 END,
		CASE WHEN t.PriceUnit * t.Qty > 0 THEN 0 ELSE ABS(ROUND(t.PriceUnit * t.Qty,@PrecCurr)) END,
		t.SumYear, t.TransId, CASE t.TransType WHEN 23 THEN 83 WHEN 24 THEN 84 WHEN 25 THEN 32 END
	FROM dbo.tblInTrans t INNER JOIN dbo.tblInItemLoc l ON t.ItemId = l.ItemId AND t.LocId = l.LocId
		 INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 	
	WHERE t.TransType IN (23,24,25) AND t.PriceUnit * t.Qty <> 0

	/*  -- Build Summary Log -- */
	IF @gInPostDtlGlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID)
		SELECT  @PostRun,[Year], Period, AcctID, SUM(DebitAmt), 'IN','Sum Trans Entry From Inv', SUM(DebitAmt), 0,
			SUM(DebitAmt), 0,'IN',@WrkStnDate,MIN(TransDate),@CurrBase,1,@CompId
		FROM #InTransPostLog
		GROUP BY [Year], Period, AcctId HAVING SUM(DebitAmt) <> 0

		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID)
		SELECT  @PostRun,[Year], Period, AcctID, SUM(CreditAmt),'IN', 'Sum Trans Entry From Inv', 0, SUM(CreditAmt),
			0, SUM(CreditAmt),'IN',@WrkStnDate,MIN(TransDate),@CurrBase,1,@CompId
		FROM #InTransPostLog
		GROUP BY [Year], Period, AcctId HAVING SUM(CreditAmt) <> 0
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,
		CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID,ItemId,LocId,LinkID,LinkIDSubLine)
		SELECT @PostRun, [Year], Period, AcctID,ABS(DebitAmt-CreditAmt),'IN',Descr,DebitAmt,
				CreditAmt,DebitAmt,CreditAmt,'IN',@WrkStnDate,TransDate,@CurrBase,1,@CompId,ItemId,LocId,TransId,[Source]
			FROM  #InTransPostLog
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransPost_GlLog_proc';


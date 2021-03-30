
CREATE PROCEDURE dbo.trav_InTransferPost_GlLog_proc
AS
BEGIN TRY
	--TransferFrom = 43
	--TransferTo = 44
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
		[Year] [smallint] NULL,
		[TransId] int NULL,
		[Source] int NULL
	)

	--From
	--Credit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, 
			Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, Source)
	SELECT t.ItemIDFrom,t.LocIDFrom,t.GlPeriod,t.XferDate,t.ItemIDFrom, g.GlAcctInv,
		CASE WHEN t.CostUnit * Qty > 0 THEN 0 ELSE ABS(ROUND(t.CostUnit * t.Qty,@PrecCurr)) END,
		CASE WHEN t.CostUnit * Qty > 0 THEN ROUND(t.CostUnit * t.Qty,@PrecCurr) ELSE 0 END,
		t.SumYear, t.TransId, 74
	FROM dbo.tblInXfers t INNER JOIN dbo.tblInGLAcct g ON t.GlAcctCodeFrom = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 
	WHERE t.CostUnit * t.Qty <> 0

	--Transfer Cost
	--Credit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, 
			Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, Source)
	SELECT t.ItemIDFrom,t.LocIDFrom,t.GlPeriod,t.XferDate,t.ItemIDFrom, g.GlAcctXferCost,
		CASE WHEN t.CostUnitXfer > 0 THEN 0 ELSE ABS(t.CostUnitXfer) END,
		CASE WHEN t.CostUnitXfer > 0 THEN t.CostUnitXfer ELSE 0 END,
		t.SumYear, t.TransId, 74
	FROM dbo.tblInXfers t INNER JOIN dbo.tblInGLAcct g ON t.GlAcctCodeFrom = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 		
	WHERE t.CostUnitXfer <> 0

	--Debit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, 
			Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, Source)
	SELECT t.ItemIDFrom,t.LocIDTo,t.GlPeriod,t.XferDate,t.ItemIDFrom, g.GlAcctInv,
		CASE WHEN t.CostUnitXfer > 0 THEN t.CostUnitXfer ELSE 0 END,
		CASE WHEN t.CostUnitXfer > 0 THEN 0 ELSE ABS(t.CostUnitXfer) END,
		t.SumYear, t.TransId, 16
	FROM dbo.tblInXfers t INNER JOIN dbo.tblInGLAcct g ON t.GlAcctCodeTo = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 		
	WHERE t.CostUnitXfer <> 0

	--To
	--Debit
	INSERT INTO #InTransPostLog (ItemID, LocID, Period, TransDate, 
			Descr, AcctID, DebitAmt, CreditAmt, [Year], TransId, Source)
	SELECT t.ItemIDTo,t.LocIDTo,t.GlPeriod,t.XferDate,t.ItemIDTo, g.GlAcctInv,
		CASE WHEN CostUnit * Qty > 0 THEN ROUND(CostUnit * Qty,@PrecCurr) ELSE 0 END,
		CASE WHEN CostUnit * Qty > 0 THEN 0 ELSE ABS(ROUND(CostUnit * Qty,@PrecCurr)) END,
		t.SumYear, t.TransId, 16
	FROM dbo.tblInXfers t INNER JOIN dbo.tblInGLAcct g ON t.GlAcctCodeTo = g.GLAcctCode
		 INNER JOIN #PostTransList p ON t.TransId = p.TransId 
	WHERE CostUnit * Qty <> 0
	

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
				CreditAmt,DebitAmt,CreditAmt,'IN',@WrkStnDate,TransDate,@CurrBase,1,@CompId,ItemId,LocId,TransId,Source
			FROM  #InTransPostLog
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_GlLog_proc';


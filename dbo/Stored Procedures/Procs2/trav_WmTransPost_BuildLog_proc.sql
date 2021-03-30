
CREATE PROCEDURE dbo.trav_WmTransPost_BuildLog_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint
		, @WksDate datetime, @CompId nvarchar(3), @PostDtlYn bit

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--populates the log table defined as follows
	--CREATE TABLE #TransactionPostLog 
	--(
	--	[Id] [int] Not Null Identity(1, 1), 
	--	[ItemID] pItemID Null, 
	--	[LocID] pLocID Null, 
	--	[TransType] smallint Null, 
	--	[TransDate] datetime Null, 
	--	[FiscalPeriod] smallint Null, 
	--	[FiscalYear] smallint Null, 
	--	[Descr] nvarchar(30) Null, 
	--	[AcctID] pGlAcct Null, 
	--	[DebitAmt] pDecimal Null, 
	--	[CreditAmt] pDecimal Null, 
	--	[Grouping] smallint Null,
	--	PRIMARY KEY ([Id])
	--)


	--create log entries for the Inventory Adjustments
	INSERT INTO #TransactionPostLog(ItemID, LocID, TransType, TransDate
		, FiscalYear, FiscalPeriod, Descr, AcctID, [Grouping]
		, DebitAmt, CreditAmt)
	SELECT t.ItemId, t.LocId, t.TransType, t.TransDate
		, t.GlYear, t.GlPeriod, t.ItemId, g.GlAcctInvAdj, 10
		, CASE WHEN t.TransType = 31 THEN Round(t.UnitCost * t.Qty, @PrecCurr) ELSE 0 END --Increase
		, CASE WHEN t.TransType <> 31 THEN Round(t.UnitCost * t.Qty, @PrecCurr) ELSE 0 END --Decrease
	FROM dbo.tblWmTrans t
	INNER JOIN #PostTransList p ON t.TransId = p.TransId
	LEFT JOIN dbo.tblInItemLoc l 
		ON t.ItemId = l.ItemId AND t.LocId = l.LocId
	LEFT JOIN dbo.tblInGlAcct g 
		ON l.GlAcctCode = g.GlAcctCode
	WHERE ROUND(t.UnitCost * t.Qty, @PrecCurr) <> 0.0


	--create log entries for the Inventory Offsets
	INSERT INTO #TransactionPostLog(ItemID, LocID, TransType, TransDate
		, FiscalYear, FiscalPeriod, Descr, AcctID, [Grouping]
		, DebitAmt, CreditAmt)
	SELECT t.ItemId, t.LocId, t.TransType, t.TransDate
		, t.GlYear, t.GlPeriod, t.ItemId, t.GlAcctOffset, 20
		, CASE WHEN t.TransType = 31 THEN 0 ELSE Round(t.UnitCost * t.Qty, @PrecCurr) END --Increase
		, CASE WHEN t.TransType <> 31 THEN 0 ELSE Round(t.UnitCost * t.Qty, @PrecCurr) END --Decrease
	FROM dbo.tblWmTrans t
	INNER JOIN #PostTransList p ON t.TransId = p.TransId
	WHERE ROUND(t.UnitCost * t.Qty, @PrecCurr) <> 0.0


	--generate the GL log entries
	IF @PostDtlYn = 0
	BEGIN
		--post summary to GL
		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate)
		SELECT @CompId, @PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, AcctID, SUM(DebitAmt - CreditAmt), 'WM', 'WM Trans'
			, CASE WHEN SUM(DebitAmt - CreditAmt) > 0 THEN SUM(DebitAmt - CreditAmt) ELSE 0 END
			, CASE WHEN SUM(DebitAmt - CreditAmt) < 0 THEN -SUM(DebitAmt - CreditAmt) ELSE 0 END
			, CASE WHEN SUM(DebitAmt - CreditAmt) > 0 THEN SUM(DebitAmt - CreditAmt) ELSE 0 END
			, CASE WHEN SUM(DebitAmt - CreditAmt) < 0 THEN -SUM(DebitAmt - CreditAmt) ELSE 0 END
			, 'WM', @WksDate, @WksDate, @CurrBase, 1.0
		FROM #TransactionPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], [AcctID]
		HAVING SUM(DebitAmt - CreditAmt) <> 0
	END
	ELSE
	BEGIN
		--post detail to GL
		INSERT #GlPostLogs(CompId, PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate
			, ItemId, LocId, LinkID, LinkIDSubLine)
		SELECT @CompId, @PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, AcctID, (DebitAmt - CreditAmt), 'WM', Descr
			, DebitAmt, CreditAmt, DebitAmt, CreditAmt
			, 'WM', @WksDate, TransDate, @CurrBase, 1.0
			, ItemId, LocId, NULL, TransType
		FROM #TransactionPostLog
	END

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_BuildLog_proc';


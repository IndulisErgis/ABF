
CREATE PROCEDURE dbo.trav_InUpdatePerpetual_GlLogDetail_proc 
@SeqNum int,
@Amount pDecimal,
@IncreaseYn bit
AS
BEGIN TRY

	DECLARE @PostRun nvarchar(14), @CurrBase pCurrency, @WrkStnDate datetime,@CompId nvarchar(3)

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @WrkStnDate IS NULL OR @CompId IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId,ItemId,LocId)
	SELECT @PostRun,b.SumYear,b.GlPeriod,10,g.GLAcctInvAdj,CASE WHEN @IncreaseYn = 1 THEN @Amount ELSE -@Amount END,
		'IN','Physical Inventory',CASE WHEN @IncreaseYn = 1 THEN @Amount ELSE 0 END,
		CASE WHEN @IncreaseYn = 1 THEN 0 ELSE @Amount END,CASE WHEN @IncreaseYn = 1 THEN @Amount ELSE 0 END, 
		CASE WHEN @IncreaseYn = 1 THEN 0 ELSE @Amount END,'IN',@WrkStnDate,b.CountDate,@CurrBase,1,@CompId,b.BatchId,c.ItemId,c.LocId
	FROM dbo.tblInPhysCountBatch b INNER JOIN dbo.tblInPhysCount c ON b.BatchId = c.BatchId 
		INNER JOIN dbo.tblInItemLoc l ON c.ItemId = l.ItemId AND c.LocId = l.LocId 
		INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
	WHERE c.SeqNum = @SeqNum

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,BatchId,ItemId,LocId)
	SELECT @PostRun,b.SumYear,b.GlPeriod,20,g.GLAcctPhyCountAdj,CASE WHEN @IncreaseYn = 1 THEN -@Amount ELSE @Amount END,
		'IN','Physical Inventory',CASE WHEN @IncreaseYn = 1 THEN 0 ELSE @Amount END,
		CASE WHEN @IncreaseYn = 1 THEN @Amount ELSE 0 END,CASE WHEN @IncreaseYn = 1 THEN 0 ELSE @Amount END, 
		CASE WHEN @IncreaseYn = 1 THEN @Amount ELSE 0 END,'IN',@WrkStnDate,b.CountDate,@CurrBase,1,@CompId,b.BatchId,c.ItemId,c.LocId
	FROM dbo.tblInPhysCountBatch b INNER JOIN dbo.tblInPhysCount c ON b.BatchId = c.BatchId 
		INNER JOIN dbo.tblInItemLoc l ON c.ItemId = l.ItemId AND c.LocId = l.LocId 
		INNER JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
	WHERE c.SeqNum = @SeqNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_GlLogDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_GlLogDetail_proc';


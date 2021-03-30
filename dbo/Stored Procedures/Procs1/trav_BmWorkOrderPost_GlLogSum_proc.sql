
CREATE PROCEDURE dbo.trav_BmWorkOrderPost_GlLogSum_proc 
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

	SELECT FiscalYear,FiscalPeriod,[Grouping],GlAccount,SUM(AmountFgn) AmountFgn,Reference,LinkId
	INTO #tmpPostLogs
	FROM #GlPostLogs 
	GROUP BY FiscalYear,FiscalPeriod,[Grouping],GlAccount,Reference,LinkId

	DELETE #GlPostLogs

	INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId, LinkId, LinkIDSub, LinkIdSubLine)
	SELECT @PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,
		'BM',Reference,CASE WHEN AmountFgn > 0 THEN AmountFgn ELSE 0 END,
		CASE WHEN AmountFgn > 0 THEN 0 ELSE ABS(AmountFgn) END,
		CASE WHEN AmountFgn > 0 THEN AmountFgn ELSE 0 END, 
		CASE WHEN AmountFgn > 0 THEN 0 ELSE ABS(AmountFgn) END,'IN',@WrkStnDate,@WrkStnDate,@CurrBase,1,@CompId,LinkId,NULL,-1
	FROM #tmpPostLogs

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_GlLogSum_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BmWorkOrderPost_GlLogSum_proc';


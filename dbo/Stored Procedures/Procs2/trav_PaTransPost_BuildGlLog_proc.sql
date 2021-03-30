
CREATE PROCEDURE [dbo].[trav_PaTransPost_BuildGlLog_proc]
AS
BEGIN TRY

	SET NOCOUNT ON

	DECLARE @PostRun pPostRun, @FiscalYear smallInt,@FiscalPeriod smallint,@CurrPrec smallint,
			@WksDate datetime, @CurrBase pCurrency, @CompID nvarchar(30)


    SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'	
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @CurrPrec= Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'
    SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
    SELECT @CompID = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'CompID'

	IF  @PostRun IS NULL OR @FiscalYear IS NULL OR @FiscalPeriod IS NULL OR @WksDate IS NULL OR @CurrBase IS NULL OR @CompID IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Expense entry
	INSERT Into #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
	, GlAccount, Reference, [Description], SourceCode
	, PostDate, TransDate, CurrencyId, ExchRate, CompId
	, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, LinkID)

	SELECT @PostRun, @FiscalYear,@FiscalPeriod, 1, h.GLAcctExpense, h.DepartmentId, 
			SUBSTRING(d.[Description],1,30),'PA',@WksDate,MIN(TransDate),@CurrBase,1,@CompID,SUM(Amount)
			, SUM(Amount), 0 , SUM(Amount) , 0 
			, NULL
	FROM dbo.tblPaAccrualHist h
	LEFT JOIN 
		(Select DepartmentId,Code,[Description] FROM dbo.tblPaDeptDtl WHERE [Type] =3 ) d  
		 ON h.DepartmentId = d.DepartmentId AND h.EarningCode = d.Code 
	WHERE  h.PostRun = @PostRun AND h.Amount >0
	GROUP BY h.GLAcctExpense,h.EarningCode,h.DepartmentId,d.[Description]
		
    -- Negative Expense amounts 
	INSERT Into #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
	, GlAccount, Reference, [Description], SourceCode
	, PostDate, TransDate, CurrencyId, ExchRate, CompId
	, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, LinkID)

	SELECT @PostRun, @FiscalYear,@FiscalPeriod, 1, h.GLAcctExpense, h.DepartmentId, 
			SUBSTRING(d.[Description],1,30),'PA',@WksDate,MIN(TransDate),@CurrBase,1,@CompID,ABS(SUM(Amount))
			, 0 , ABS(SUM(Amount)) ,0 , ABS(SUM(Amount))
			, NULL
	FROM dbo.tblPaAccrualHist h
	LEFT JOIN 
		(Select DepartmentId,Code,[Description] FROM dbo.tblPaDeptDtl WHERE [Type] =3 ) d  
		 ON h.DepartmentId = d.DepartmentId AND h.EarningCode = d.Code 
	WHERE  h.PostRun = @PostRun AND h.Amount < 0
	GROUP BY h.GLAcctExpense,h.EarningCode,h.DepartmentId,d.[Description]


	--Accrual Entry			
	INSERT Into #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
	, GlAccount, Reference, [Description], SourceCode
	, PostDate, TransDate, CurrencyId, ExchRate, CompId
	, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, LinkIDSubLine)

	SELECT @PostRun, @FiscalYear,@FiscalPeriod, 1,GLAcctAccrual , MIN(SUBSTRING((h.DepartmentId + '-Accr'),1,15)), 
			MIN(SUBSTRING(d.[Description],1,30)),'PA',@WksDate,MIN(TransDate),@CurrBase,1,@CompID,SUM(Amount)
			, 0 , SUM(Amount), 0 , SUM(Amount) 
			,'-1'
	FROM dbo.tblPaAccrualHist h
	LEFT JOIN (Select DepartmentId,[Description] FROM dbo.tblPaDeptDtl WHERE [Type] =7 AND Code = 'ACW' ) d 
			   ON h.DepartmentId = d.DepartmentId 
	WHERE  h.PostRun = @PostRun AND h.Amount > 0
	GROUP BY h.DepartmentId,h.GLAcctAccrual
	


	-- Negative Accrual amounts
	INSERT Into #GlPostLogs(PostRun, FiscalYear, FiscalPeriod, [Grouping]
	, GlAccount, Reference, [Description], SourceCode
	, PostDate, TransDate, CurrencyId, ExchRate, CompId
	, AmountFgn, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn, LinkIDSubLine)

	SELECT @PostRun, @FiscalYear,@FiscalPeriod, 1,GLAcctAccrual , MIN(SUBSTRING((h.DepartmentId + '-Accr'),1,15)), 
			MIN(SUBSTRING(d.[Description],1,30)),'PA',@WksDate,MIN(TransDate),@CurrBase,1,@CompID,SUM(Amount)
			, ABS(SUM(Amount)) , 0 , ABS(SUM(Amount)) , 0 
			,'-1'
	FROM dbo.tblPaAccrualHist h
	LEFT JOIN (Select DepartmentId,[Description] FROM dbo.tblPaDeptDtl WHERE [Type] =7 AND Code = 'ACW' ) d 
			   ON h.DepartmentId = d.DepartmentId 
	WHERE  h.PostRun = @PostRun AND h.Amount < 0
	GROUP BY h.DepartmentId,h.GLAcctAccrual




END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPost_BuildGlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPost_BuildGlLog_proc';


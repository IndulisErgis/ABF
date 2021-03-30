

CREATE PROCEDURE dbo.trav_PaCheckPost_UpdateAccrualHist_proc 
AS

BEGIN TRY

	SET NOCOUNT ON
	DECLARE @PostRun pPostRun, @PaYear smallint,@PaMonth smallint,@CurrPrec smallint,
			@WksDate datetime,@DateOnCheck Datetime, @GlPeriod  smallint,@PostYear smallint

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PaMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'iMonth' --payroll month
	SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear' --PayrollContext.PayrollYear
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate' -- current wrk station date
	SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'-- checkinfo.Checkdate
	SELECT @GlPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'GlPeriod' -- checkinfo.GlPeriod
	SELECT @PostYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear'-- checkinfo.GLYear

	IF  @PostRun IS NULL OR @PaMonth IS NULL OR @PaYear IS NULL  OR @WksDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT dbo.tblPaAccrualHist(PostRun, TransId, EmployeeId, DepartmentId, EarningCode, EntryDate, TransDate, PaYear, PaMonth, FiscalYear
								, FiscalPeriod, GLAcctAccrual, GLAcctExpense, Amount)
	SELECT @PostRun, t.Id, EmployeeId, t.DepartmentId, EarningCode, @WksDate, @DateOnCheck, @PaYear, @PaMonth,  @PostYear
		, @GlPeriod, ac.GLAcctAccrual, ex.GLAcctExpense, -Amount
	FROM dbo.tblPaTransEarn t
	INNER JOIN  dbo.tblPaCheckTrans ct on t.Id = ct.TransId AND ct.TransType = 0 
	INNER JOIN #PostTransList b ON ct.CheckId = b.TransId 
	INNER JOIN dbo.tblPaEarnCode e ON t.EarningCode= e.Id 
	LEFT JOIN 
	(
		SELECT GlAcct GLAcctAccrual,DepartmentId 
		FROM dbo.tblPaDeptDtl 
		WHERE TYPE=7 AND Code='ACW'
	)ac ON ac.DepartmentId =t.DepartmentId
	LEFT JOIN 
	(
		SELECT GlAcct GLAcctExpense,DepartmentId, Code 
		FROM dbo.tblPaDeptDtl 
		WHERE TYPE=3 
	) ex ON ex.DepartmentId =t.DepartmentId AND ex.Code =t.EarningCode
	WHERE e.IncludeInNet =1 AND t.Amount<>0


END TRY

BEGIN CATCH

	EXEC dbo.trav_RaiseError_proc

END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateAccrualHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateAccrualHist_proc';


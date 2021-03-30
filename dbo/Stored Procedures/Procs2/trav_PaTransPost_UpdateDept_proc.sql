
CREATE PROCEDURE [dbo].[trav_PaTransPost_UpdateDept_proc]
AS
BEGIN TRY

	SET NOCOUNT ON
	DECLARE  @PaYear smallint,@PaMonth smallint,@WksDate datetime
	DECLARE	@Hours smallint, @Earnings smallint, @Pieces smallint, @Accrual smallint,@AccruedWages smallint

	
	SELECT @Hours = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Hours'
    SELECT @Earnings = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Earnings'
    SELECT @Pieces = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Pieces'
    SELECT @PaMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaMonth'
	SELECT @PaYear =  Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
	
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'
	SELECT @Accrual = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Accrual'
	SELECT @AccruedWages = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'AccruedWages'

	IF  @Hours IS NULL OR @Earnings IS NULL OR  @Pieces IS NULL OR @PaMonth IS NULL OR @PaYear IS NULL OR @WksDate IS NULL
		OR @Accrual IS NULL OR @AccruedWages IS NULL  
	BEGIN
		RAISERROR(90025,16,1)
	END



	INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
	SELECT d.Id, @PaYear, @PaMonth, t.Pieces , @WksDate
	FROM (dbo.tblPaDeptDtl d 
	INNER JOIN dbo.tblPaTransEarn t ON d.DepartmentId = t.DepartmentId
	INNER JOIN  #PostTransEarnList p ON p.TransId = t.Id) 
	WHERE d.Type =  @Pieces AND t.Pieces <>0

	UNION ALL

	SELECT  d.Id, @PaYear, @PaMonth, t.[Hours], @WksDate
	FROM (dbo.tblPaDeptDtl d 
	INNER JOIN dbo.tblPaTransEarn t ON d.DepartmentId = t.DepartmentId
	INNER JOIN  #PostTransEarnList p ON p.TransId = t.Id)  
	WHERE d.Type =  @Hours AND t.[Hours] <>0

	UNION ALL

	SELECT d.Id, @PaYear,@PaMonth, t.Amount, @WksDate
	FROM dbo.tblPaDeptDtl d 
	INNER JOIN dbo.tblPaTransEarn t  ON d.Code = t.EarningCode AND d.DepartmentId = t.DepartmentId
	INNER JOIN  #PostTransEarnList p ON p.TransId = t.Id  
	WHERE d.Type = @Earnings AND t.Amount <>0
	

	IF(@Accrual = 1) 
	BEGIN
		INSERT INTO dbo.tblPaDeptDtlAmount(DeptDtlId, PaYear, PaMonth, Amount, EntryDate)
		SELECT d.Id, @PaYear, @PaMonth,t.Amount,@WksDate
		FROM dbo.tblPaTransEarn t
		INNER JOIN  #PostTransEarnList p ON p.TransId = t.Id 
		INNER JOIN dbo.tblPaDeptDtl d ON t.DepartmentId = d.DepartmentId
		INNER JOIN dbo.tblPaEarnCode e ON t.EarningCode =e.Id
		WHERE d.Code = 'ACW' AND d.Type = @AccruedWages AND e.IncludeInNet=1 AND t.Amount <>0
	END


	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPost_UpdateDept_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPost_UpdateDept_proc';


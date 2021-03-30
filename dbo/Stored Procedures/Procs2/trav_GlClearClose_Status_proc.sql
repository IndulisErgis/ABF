
CREATE PROCEDURE dbo.trav_GlClearClose_Status_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @FiscalYear smallint, @StepFrom tinyint, @StepThru tinyint

	--Retrieve global values
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @StepFrom = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepFrom'
	SELECT @StepThru = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepThru'

	IF @FiscalYear IS NULL OR @StepFrom IS NULL OR @StepThru IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	SELECT Count(h.ClearToAcct) AccountCount
		, Sum(Case When BalType = -1 Then isnull(s.Actual, 0) Else 0 End) RevenueAccountTotal
		, Sum(Case When BalType = 1 Then isnull(s.Actual, 0) Else 0 End) ExpenseAccountTotal
		FROM dbo.tblGlAcctHdr h 
		INNER JOIN (SELECT d.AcctId, d.[Year], Sum(d.Actual) Actual
			FROM dbo.tblGlAcctDtl d 
			WHERE d.[Year] = @FiscalYear
			GROUP BY d.AcctId, d.[Year]
		) s on h.AcctId = s.AcctId
	WHERE h.ClearToStep Between @StepFrom And @StepThru

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlClearClose_Status_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlClearClose_Status_proc';


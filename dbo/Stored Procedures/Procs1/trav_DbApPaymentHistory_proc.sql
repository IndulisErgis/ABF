CREATE PROCEDURE [dbo].[trav_DbApPaymentHistory_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @FiscalYear smallint, @Period smallint	
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	-- return resultset
		SELECT 
	ROUND(ISNULL(SUM(CASE WHEN PmtType = 3 AND GlPeriod = @Period AND FiscalYear = @FiscalYear THEN 
			CASE WHEN @Foreign = 0 THEN (GrossAmtDue-DiscAmt) ELSE (GrossAmtDueFgn-DiscAmtFgn) END ELSE 0 END),0),@Prec) AS PrepaidPTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType = 3 AND GlPeriod <= @Period AND FiscalYear = @FiscalYear THEN 
			CASE WHEN @Foreign = 0 THEN  (GrossAmtDue-DiscAmt) ELSE (GrossAmtDueFgn-DiscAmtFgn) END ELSE 0 END),0),@Prec) AS PrepaidYTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType = 3 AND GlPeriod = @Period AND FiscalYear = @FiscalYear AND DiscTaken <> 0 THEN 
			CASE WHEN @Foreign = 0 THEN DiscAmt ELSE DiscAmtFgn END ELSE 0 END),0), @Prec) AS PrepaidDiscPTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType = 3 AND GlPeriod <= @Period AND FiscalYear = @FiscalYear AND DiscTaken <> 0 THEN 
			CASE WHEN @Foreign = 0 THEN DiscAmt ELSE DiscAmtFgn END ELSE 0 END),0),@Prec) AS PrepaidDiscYTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType IN(0, 4) AND GlPeriod = @Period AND FiscalYear = @FiscalYear THEN 
			CASE WHEN @Foreign = 0 THEN (GrossAmtDue-DiscAmt) ELSE (GrossAmtDueFgn-DiscAmtFgn) END ELSE 0 END),0),@Prec) AS RegCheckPTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType IN(0, 4) AND GlPeriod <= @Period AND FiscalYear = @FiscalYear THEN 
			CASE WHEN @Foreign = 0 THEN (GrossAmtDue-DiscAmt) ELSE (GrossAmtDueFgn-DiscAmtFgn) END ELSE 0 END),0),@Prec) AS RegCheckYTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType IN(0, 4) AND GlPeriod = @Period AND FiscalYear = @FiscalYear AND DiscTaken <> 0 THEN 
			CASE WHEN @Foreign = 0 THEN DiscAmt ELSE DiscAmtFgn END ELSE 0 END),0),@Prec) AS RegCheckDiscPTD
		, ROUND(ISNULL(SUM(CASE WHEN PmtType IN(0, 4) AND GlPeriod <= @Period AND FiscalYear = @FiscalYear AND DiscTaken <> 0 THEN 
			CASE WHEN @Foreign = 0 THEN DiscAmt ELSE DiscAmtFgn END ELSE 0 END),0), @Prec) AS RegCheckDiscYTD
	FROM dbo.tblApCheckHist-- PmtType 0 = Payment, 3 = Prepayment, 4 = Manual, 9 = Void
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApPaymentHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbApPaymentHistory_proc';


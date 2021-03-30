
CREATE PROCEDURE [dbo].[trav_DbChecksWritten_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null
AS
BEGIN TRY
	SET NOCOUNT ON

	
	DECLARE  @BegDate datetime
	DECLARE @ApTotToday pDecimal, @ApTotPTD pDecimal ,@ApTotYTD pDecimal
	DECLARE @ApTotInProcess pDecimal
	DECLARE @PaNetHistToday pDecimal, @PaVoidHistToday pDecimal, @PaNetHistPTD pDecimal, @PaVoidHistPTD pDecimal,@PaNetHistYTD pDecimal, @PaVoidHistYTD pDecimal
	DECLARE @PaTotInProcess pDecimal
DECLARE  @Period smallint,@FiscalYear smallint

	SELECT @FiscalYear = GlYear, @Period = GlPeriod, @BegDate = BegDate 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	/*  ApPaymentHistory  */
	SELECT @ApTotToday = TotToday, @ApTotPTD = TotPTD , @ApTotYTD = TotYTD
	FROM 
	(
		SELECT SUM(CASE WHEN PmtType IN(0, 3, 4) AND CheckDate = @WksDate THEN 
				CASE WHEN @Foreign = 0 THEN (GrossAmtDue - DiscAmt) ELSE (GrossAmtDueFgn - DiscAmtFgn) END 
				ELSE 0 END) AS TotToday
			, SUM(CASE WHEN PmtType IN(0, 3, 4) AND GlPeriod = @Period AND FiscalYear = @FiscalYear THEN 
				CASE WHEN @Foreign = 0 THEN (GrossAmtDue - DiscAmt) ELSE (GrossAmtDueFgn - DiscAmtFgn) END 
				ELSE 0 END) AS TotPTD 
				, SUM(CASE WHEN PmtType IN(0, 3, 4) AND  FiscalYear = @FiscalYear AND GLPeriod <= @Period THEN 
				CASE WHEN @Foreign = 0 THEN (GrossAmtDue - DiscAmt) ELSE (GrossAmtDueFgn - DiscAmtFgn) END 
				ELSE 0 END) AS TotYTD 
		FROM dbo.tblApCheckHist
	) tmp --PmtType 0 = Payment, 3 = Prepayment, 4 = Manual, 9 = Void


	/*  ApPrepChkCtrl  */
	SELECT @ApTotInProcess = TotInProcess 
	FROM 
	(
		SELECT SUM(CASE WHEN @Foreign = 0 THEN (PrepaidCheckTotal + CheckAmountTotal) 
			ELSE (PrepaidCheckTotalFgn + CheckAmountTotalFgn) END) AS TotInProcess 
		FROM dbo.tblApPrepChkCntl
	) tmp

	/*  PaCheckHistory  */
	SELECT @PaNetHistToday = SUM(CASE WHEN Voided = 0 AND CheckDate = @WksDate THEN NetPay ELSE 0 END)
		, @PaVoidHistToday = SUM(CASE WHEN Voided = 1 AND CheckDate = @WksDate THEN NetPay ELSE 0 END)
		, @PaNetHistPTD = SUM(CASE WHEN Voided = 0 AND GlPeriod = @Period AND GlYear = @FiscalYear THEN NetPay ELSE 0 END)
		, @PaVoidHistPTD = SUM(CASE WHEN Voided = 1 AND GlPeriod = @Period AND GlYear = @FiscalYear THEN NetPay ELSE 0 END) 
		--, @PaNetHistPTD = SUM(CASE WHEN Voided = 0 AND CheckDate BETWEEN @BegDate AND @WksDate THEN NetPay ELSE 0 END)
		--, @PaVoidHistPTD = SUM(CASE WHEN Voided = 1 AND CheckDate BETWEEN @BegDate AND @WksDate THEN NetPay ELSE 0 END) 
	,@PaNetHistYTD =SUM(CASE WHEN Voided = 0  AND GlYear = @FiscalYear AND GLPeriod <= @Period THEN NetPay ELSE 0 END)
	 ,@PaVoidHistYTD =SUM(CASE WHEN Voided = 1 AND GlYear = @FiscalYear AND GLPeriod <= @Period THEN NetPay ELSE 0 END) 
	FROM dbo.tblPaCheckHist
	
	/*  PaChecksWritten  */
	SELECT @PaTotInProcess = SUM(CASE WHEN CheckDate <= @WksDate THEN NetPay ELSE 0 END)
	FROM dbo.tblPaCheck
	
	-- return resultset
	SELECT ISNULL(@ApTotInProcess, 0) AS ApTotInProcess
		, ISNULL(@ApTotPTD, 0) AS ApTotPTD
		, ISNULL(@ApTotToday, 0) AS ApTotToday
		,ISNULL(@ApTotYTD,0) AS ApTotYTD
		, ISNULL(@PaTotInProcess, 0) AS PaTotInProcess
			, ISNULL(@PaNetHistPTD, 0)  AS PaTotPTD
		, ISNULL(@PaNetHistToday, 0) AS PaTotToday
		, ISNULL(@PaNetHistYTD, 0)  AS PaTotYTD
		END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbChecksWritten_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbChecksWritten_proc';



CREATE PROCEDURE [dbo].[trav_DbCashReceipts_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =  null
AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #ArCashReceipts
	(
		Cash pDecimal, 
		Checks pDecimal, 
		CreditCards pDecimal, 
		Writeoffs pDecimal, 
		Other pDecimal, 
		DirectDebit pDecimal,
		RcvdToday pDecimal, 
		RcvdPTD pDecimal
	)

	CREATE TABLE #ArPaymentHist
	(
		PmtsToday pDecimal, 
		PmtsPTD pDecimal
	)

	DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	INSERT INTO #ArCashReceipts(Cash, Checks, CreditCards, Writeoffs, Other,DirectDebit, RcvdToday, RcvdPTD) 
	SELECT ISNULL(SUM(CASE WHEN PmtType = 1 AND PmtDate <= @WksDate THEN d.PmtAmt ELSE 0 END), 0) AS Cash
		, ISNULL(SUM(CASE WHEN PmtType = 2 AND PmtDate <= @WksDate 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS Checks
		, ISNULL(SUM(CASE WHEN (PmtType = 3 OR PmtType = 7) AND PmtDate <= @WksDate 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS CreditCards
		, ISNULL(SUM(CASE WHEN PmtType = 4 AND PmtDate <= @WksDate 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS Writeoffs
		, ISNULL(SUM(CASE WHEN PmtType = 5 AND PmtDate <= @WksDate 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS Other
		, ISNULL(SUM(CASE WHEN PmtType = 6 AND PmtDate <= @WksDate 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS DirectDebit
		, ISNULL(SUM(CASE WHEN PmtDate = @WksDate THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS RcvdToday
		, ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period 
			THEN (d.PmtAmt + d.CalcGainLoss) ELSE 0 END), 0) AS RcvdPTD 
	FROM dbo.tblArCashRcptHeader h 
	LEFT JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderId = d.RcptHeaderId 
	LEFT JOIN dbo.tblArPmtMethod p ON h.PmtMethodId = p.PmtMethodId

	INSERT INTO #ArPaymentHist(PmtsToday, PmtsPTD) 
	SELECT ISNULL(SUM(CASE WHEN PmtDate = @WksDate THEN PmtAmt ELSE 0 END), 0) AS PmtsToday
		, ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND GLPeriod = @Period THEN PmtAmt ELSE 0 END), 0) AS PmtsPTD 
	FROM dbo.tblArHistPmt WHERE VoidYn = 0

	-- return resultset
	SELECT ISNULL(SUM(Cash),0) AS Cash
		, ISNULL(SUM(Checks),0) AS Checks
		, ISNULL(SUM(CreditCards),0) AS CreditCards
		, ISNULL(SUM(Writeoffs),0) AS Writeoffs
		, ISNULL(SUM(Other),0) AS Other
		, ISNULL(SUM(DirectDebit),0) As DirectDebit
		, ISNULL(SUM(RcvdToday + PmtsToday),0) AS RcvdToday
		, ISNULL(SUM(RcvdPTD + PmtsPTD),0) AS RcvdPTD 
	FROM #ArCashReceipts, #ArPaymentHist
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCashReceipts_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbCashReceipts_proc';


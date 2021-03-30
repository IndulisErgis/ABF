
CREATE PROCEDURE [dbo].[trav_DbSummaryRatioAnalysis_proc]
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Wksdate datetime =   null,
@DefaultBFRef int=0
AS
BEGIN TRY
	SET NOCOUNT ON

	CREATE TABLE #SummaryRatioAnalysis
	(
		RatioCA pDecimal DEFAULT(0), 
		RatioCL pDecimal DEFAULT(0), 
		RatioCredit pDecimal DEFAULT(0), 
		RatioDebt pDecimal DEFAULT(0), 
		RatioQA55 pDecimal DEFAULT(0), 
		RatioQA5to20 pDecimal DEFAULT(0), 
	)
DECLARE @FiscalYear smallint, @Period smallint
	
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	INSERT INTO #SummaryRatioAnalysis (RatioCA, RatioCL, RatioCredit
			, RatioDebt, RatioQA55, RatioQA5to20) 
		SELECT ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear  AND d.Period <= @Period AND h.AcctTypeId BETWEEN 5 AND 99 
		THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) 
				ELSE 0 END),0) AS RatioCA
			, ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period AND h.AcctTypeId BETWEEN 200 AND 299 
				THEN (CASE BalType WHEN -1 THEN ISNULL(d.Actual, 0) ELSE ISNULL(-d.Actual, 0) END) 
				ELSE 0 END),0) AS RatioCL
			, ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period AND h.AcctTypeId BETWEEN 400 AND 899 
				THEN (CASE BalType WHEN -1 THEN ISNULL(d.Actual, 0) ELSE ISNULL(-d.Actual, 0) END) 
				ELSE 0 END),0) AS RatioCredit
			, ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period AND h.AcctTypeId BETWEEN 200 AND 399 
				THEN (CASE BalType WHEN -1 THEN ISNULL(d.Actual, 0) ELSE ISNULL(-d.Actual, 0) END) 
				ELSE 0 END),0) AS RatioDebt
			, ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period	AND h.AcctTypeId = 55 
				THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) 
				ELSE 0 END),0)AS RatioQA55
			, ISNULL(SUM(CASE WHEN d.[Year] = @FiscalYear AND d.Period <= @Period AND h.AcctTypeId BETWEEN 5 AND 20 
				THEN (CASE BalType WHEN -1 THEN ISNULL(-d.Actual, 0) ELSE ISNULL(d.Actual, 0) END) 
				ELSE 0 END),0) AS RatioQA5to20 
		FROM dbo.tblGlAcctHdr h 
			LEFT JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 
			LEFT JOIN (SELECT AcctId, GlYear, GlPeriod, Amount FROM dbo.tblGlAcctDtlBudFrcst 
					WHERE BFRef = @DefaultBFRef) b 
				ON d.AcctId = b.AcctId AND d.[Year] = b.GlYear AND d.[Period] = b.GlPeriod
			SELECT LTRIM(STR(CASE WHEN [RatioCL] = 0 THEN 0	ELSE ([RatioCA] / [RatioCL]) END, 20,2)) + ':1' AS CurrRatio
			, LTRIM(STR(CASE WHEN [RatioCredit] = 0 THEN 0 
				ELSE ([RatioDebt] / [RatioCredit]) END, 20,2)) + ':1' AS DebtEquity
			, LTRIM(STR(CASE WHEN [RatioCL] = 0 THEN 0 
				ELSE (([RatioQA5to20] + [RatioQA55]) / [RatioCL]) END, 20,2)) + ':1' AS QuickRatio 
		FROM #SummaryRatioAnalysis
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummaryRatioAnalysis_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbSummaryRatioAnalysis_proc';


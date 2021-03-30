
CREATE PROCEDURE dbo.trav_GlCashFlowReport_Result_proc
@FiscalYear1 smallint = 2009,
@FiscalYear2 smallint = 2010,
@FiscalPeriodFrom smallint = 1,
@FiscalPeriodThru smallint = 12
AS
SET NOCOUNT ON

UPDATE #CashFlowRpt SET Actual1 = Actual1 - 
	(SELECT COALESCE(SUM(Amount), 0) FROM #GlJrnlExclude WHERE AcctId = #CashFlowRpt.AcctId AND FiscalYear = @FiscalYear1
		AND FiscalPeriod BETWEEN @FiscalPeriodFrom AND @FiscalPeriodThru)

UPDATE #CashFlowRpt SET Actual2 = Actual2 - 
	(SELECT COALESCE(SUM(Amount), 0) FROM #GlJrnlExclude WHERE AcctId = #CashFlowRpt.AcctId AND FiscalYear = @FiscalYear2
		AND FiscalPeriod BETWEEN @FiscalPeriodFrom AND @FiscalPeriodThru)

UPDATE #CashFlowRpt SET Cash1 = Cash1 - 
	(SELECT COALESCE(SUM(Amount), 0) FROM #GlJrnlExclude WHERE AcctId = #CashFlowRpt.AcctId AND FiscalYear = @FiscalYear1
		AND FiscalPeriod < @FiscalPeriodFrom)

UPDATE #CashFlowRpt SET Cash2 = Cash2 - 
	(SELECT COALESCE(SUM(Amount), 0) FROM #GlJrnlExclude WHERE AcctId = #CashFlowRpt.AcctId AND FiscalYear = @FiscalYear2
		AND FiscalPeriod < @FiscalPeriodFrom)

UPDATE #CashFlowRpt SET LineNum = d.LineNum, ClassId = d.ClassId, CashFlowDesc = d.[Desc]
FROM #CashFlowRpt INNER JOIN #CashFlowDtl d 
	ON #CashFlowRpt.AcctTypeId BETWEEN d.BegAcctTypeId AND d.EndAcctTypeId 

SELECT LineNum AS FirstOfLineNum, CashFlowDesc AS CashFlowDescr, 
	CASE ClassId WHEN 3 THEN 'B' WHEN 2 THEN 'C' WHEN 1 THEN 'D' WHEN 0 THEN 'A' ELSE ' ' END ClassId, 
	AcctTypeId, AcctId, [Desc] AS Descr,  
	CASE ClassId WHEN 1 THEN Cash1 ELSE CASE WHEN AcctCode = 1 THEN -Actual1 ELSE Actual1 END END SumOfActualYr1, 
	CASE ClassId WHEN 1 THEN Cash2 ELSE CASE WHEN AcctCode = 1 THEN -Actual2 ELSE Actual2 END END SumOfActualYr2
FROM #CashFlowRpt 
WHERE (AcctTypeId >= 500 And AcctTypeId <= 890) OR LineNum > 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCashFlowReport_Result_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCashFlowReport_Result_proc';


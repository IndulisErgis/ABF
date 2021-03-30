
CREATE PROCEDURE dbo.trav_GlCashFlowReport_BuildContent_proc
@FiscalYear1 smallint = 2007,
@FiscalYear2 smallint = 2008,
@FiscalPeriodFrom smallint = 1,
@FiscalPeriodThru smallint = 12
AS

SET NOCOUNT ON

INSERT INTO #CashFlowRpt (AcctId,[Desc],AcctTypeId,AcctCode) 
SELECT h.AcctId,h.[Desc],h.AcctTypeId,p.AcctCode
FROM dbo.tblGlAcctHdr h INNER JOIN #tmpAccountList t ON h.AcctId = t.AcctId 
	INNER JOIN tblGlAcctType p ON h.AcctTypeId = p.AcctTypeId
WHERE h.AcctId NOT IN (SELECT AcctId FROM #CashFlowRpt)

UPDATE #CashFlowRpt SET Actual1 = Actual1 + 
	(SELECT ISNULL(SUM(ActualBase), 0) FROM dbo.tblGLAcctDtl 
		WHERE AcctId = #CashFlowRpt.AcctId AND [Year] = @FiscalYear1 AND 
			Period BETWEEN @FiscalPeriodFrom AND @FiscalPeriodThru)

UPDATE #CashFlowRpt SET Actual2 = Actual2 + 
	(SELECT ISNULL(SUM(ActualBase), 0) FROM dbo.tblGLAcctDtl 
		WHERE AcctId = #CashFlowRpt.AcctId AND [Year] = @FiscalYear2 AND 
			Period BETWEEN @FiscalPeriodFrom AND @FiscalPeriodThru)

UPDATE #CashFlowRpt SET Cash1 = Cash1 + 
	(SELECT ISNULL(SUM(ActualBase), 0) FROM dbo.tblGLAcctDtl 
		WHERE AcctId = #CashFlowRpt.AcctId AND [Year] = @FiscalYear1 AND 
			Period < @FiscalPeriodFrom)

UPDATE #CashFlowRpt SET Cash2 = Cash2 + 
	(SELECT ISNULL(SUM(ActualBase), 0) FROM dbo.tblGLAcctDtl 
		WHERE AcctId = #CashFlowRpt.AcctId AND [Year] = @FiscalYear2 AND 
			Period < @FiscalPeriodFrom)

INSERT INTO #GlJrnlExclude (AcctId, FiscalYear, FiscalPeriod, Amount)
SELECT j.AcctId, j.[Year], j.Period, SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END)
FROM dbo.tblGlJrnl j INNER JOIN dbo.tblGlAcctHdr h On j.AcctId = h.AcctId 
	INNER JOIN #tmpAccountList t ON h.AcctId = t.AcctId 
WHERE j.PostedYN <> 0 AND j.CashFlow = 0 AND j.Period <= @FiscalPeriodThru 
	AND (j.[Year] = @FiscalYear1 OR [Year] = @FiscalYear2)
Group By j.AcctId, j.[Year], j.Period
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCashFlowReport_BuildContent_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCashFlowReport_BuildContent_proc';


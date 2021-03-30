
CREATE VIEW dbo.pvtGlCompAnalysis
AS
SELECT case when h.BalType = 1 then 'Debit' when h.BalType = 0 then 'Memo' else 'Credit' end as [BalType$]
	, h.[Desc], h.AcctIdMasked, dtl.GlYear AS [Year], dtl.GlPeriod AS [Period]
	, ISNULL(SUM(dtl.Actual), 0) AS Actual
	, ISNULL(SUM(dtl.Budget), 0) AS Budget
	, ISNULL(SUM(dtl.Forecast), 0) AS Forecast
	FROM dbo.trav_GlAccountHeader_view h
	LEFT JOIN 
	(
		SELECT d.AcctId, d.[Year] AS GlYear, d.Period AS GlPeriod, d.Actual, 0 AS Budget, 0 AS Forecast
			FROM dbo.tblGlAcctDtl d
		UNION ALL
		--the following code must be customized per installation to identify the system database
		--SELECT abf.AcctID, abf.GlYear, abf.GlPeriod, 0 AS Actual, abf.Amount AS Budget, 0 AS Forecast
		--	FROM dbo.tblGlAcctDtlBudFrcst abf
		--	INNER JOIN [SYSV11].dbo.tblGlBudFrcstComp c on abf.BFRef = c.BFRef
		--	INNER JOIN [SYSV11].dbo.tblGLBudFrcstDescr d on c.BFRef = d.BFRef
		--	WHERE d.BFType = 0 --budget
		--		AND c.DefaultYn = 1 and c.CompId = LEFT(db_name(), 3)
		--UNION ALL
		--the following code must be customized per installation to identify the system database
		--SELECT abf.AcctID, abf.GlYear, abf.GlPeriod, 0 AS Actual, 0 AS Budget, abf.Amount AS Forecast
		--	FROM dbo.tblGlAcctDtlBudFrcst abf
		--	INNER JOIN [SYSV11].dbo.tblGlBudFrcstComp c on abf.BFRef = c.BFRef
		--	INNER JOIN [SYSV11].dbo.tblGLBudFrcstDescr d on c.BFRef = d.BFRef
		--	WHERE d.BFType = 1 --Forecast
		--		AND c.DefaultYn = 1 and c.CompId = LEFT(db_name(), 3)
		--UNION ALL
		SELECT h.AcctId, p.GlYear, p.GlPeriod, 0 AS Actual, 0 AS Budget, 0 AS Forecast
			FROM dbo.tblGlAcctHdr h CROSS JOIN dbo.tblSmPeriodConversion p
	) dtl ON h.AcctId = dtl.AcctId
GROUP BY h.[BalType], h.[Desc], h.AcctIdMasked, dtl.GlYear, dtl.GlPeriod
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlCompAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtGlCompAnalysis';


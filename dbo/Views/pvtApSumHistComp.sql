
CREATE VIEW dbo.pvtApSumHistComp
AS
--PET:http://webfront:801/view.php?id=238925

SELECT a.[GlYear] AS [Year], a.[GlPeriod] AS Period
	, ISNULL(SUM([NumOfPurch]), 0) AS NumOfPurch
	, ISNULL(SUM([TotPurch]), 0) AS TotPurch
	, ISNULL(SUM([PrepaidAmt]), 0) AS PrepaidAmt
	, ISNULL(SUM([TotDiscTaken]), 0) AS TotDiscTaken
	, ISNULL(SUM([TotDiscLost]), 0) AS TotDiscLost
	, ISNULL(SUM([PurchNoDisc]), 0) AS PurchNoDisc
	, ISNULL(SUM([PurchDiscTaken]), 0) AS PurchDiscTaken
	, ISNULL(SUM([PurchDiscLost]), 0) AS PurchDiscLost
	, ISNULL(SUM([TotPmt]), 0) AS TotPmt
	, SUM(ISNULL([TotPurch], 0) - ISNULL([TotPmt], 0) - ISNULL([TotDiscTaken], 0)) AS GrossDue
FROM dbo.tblSmPeriodConversion a 
LEFT JOIN (
	SELECT [FiscalYear], [GlPeriod]
		, SUM([NumOfPurch]) AS NumOfPurch, SUM([TotPurch]) AS TotPurch
		, SUM([PrepaidAmt]) AS PrepaidAmt
		, 0 AS TotDiscTaken, 0 AS TotDiscLost, 0 AS PurchNoDisc
		, 0 AS PurchDiscTaken, 0 AS PurchDiscLost, 0 AS TotPmt 
	FROM dbo.trav_ApHistHeaderSUMbyVendor_view
	GROUP BY [FiscalYear], [GlPeriod]

	UNION ALL
	
	SELECT [FiscalYear], [GlPeriod]
		, 0 AS NumOfPurch, 0 AS TotPurch, 0 AS PrepaidAmt
		, SUM([TotDiscTaken]) AS TotDiscTaken, SUM([TotDiscLost]) AS TotDiscLost
		, SUM([PurchNoDisc]) AS PurchNoDisc, SUM([PurchDiscTaken]) AS PurchDiscTaken
		, SUM([PurchDiscLost]) AS PurchDiscLost, SUM([TotPmt]) AS TotPmt
	FROM dbo.trav_ApCheckHistSumbyVendor_view 
	GROUP BY [FiscalYear], [GlPeriod]

	) tmp ON a.[GlYear] = tmp.[FiscalYear] AND a.[GlPeriod] = tmp.[GlPeriod]
GROUP BY a.[GlYear], a.[GlPeriod]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApSumHistComp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtApSumHistComp';


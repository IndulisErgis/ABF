
CREATE PROCEDURE dbo.trav_DbTopSalesRepList_proc
@Prec tinyint = 2, 
@Timeframe tinyint = 0, -- 0 = All Time, 1 = PTD, 2 = YTD
@RecReturn int = 10 ,
@Wksdate datetime = null,
@returnValue nvarchar(10) = 'S' 
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE  @Period smallint,@FiscalYear smallint

	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

	SET ROWCOUNT @RecReturn
	
	SELECT r.SalesRepId, r.[Name] as SalesRepName
			, ROUND(SUM(ISNULL(Sales, 0)), @Prec) AS Sales
			, ROUND(SUM(ISNULL(COGS, 0)), @Prec) AS COGS
			, ROUND(SUM(ISNULL(Profit, 0)), @Prec) AS Profit 
		FROM dbo.tblArSalesRep r 
			LEFT JOIN 
			(	SELECT ISNULL(d.Rep1Id, h.Rep1Id) RepId
					, SUM(SIGN(h.TransType) * d.PriceExt) AS Sales
					, SUM(SIGN(h.TransType) * d.CostExt) AS COGS
					, SUM(SIGN(h.TransType) * (d.PriceExt - d.CostExt)) AS Profit 
					FROM dbo.tblArHistHeader h
					INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun and h.TransId = d.TransId
					WHERE h.VoidYn = 0 AND d.EntryNum >= 0 AND d.GrpId IS NULL AND ISNULL(d.Rep1Id, h.Rep1Id) IS NOT NULL
						AND ((@Timeframe = 1 AND (GLPeriod = @Period AND FiscalYear = @FiscalYear))
							OR (@Timeframe = 2 AND (GLPeriod <= @Period AND FiscalYear = @FiscalYear))
							OR (@Timeframe NOT IN (1, 2)))
					GROUP BY ISNULL(d.Rep1Id, h.Rep1Id)
				UNION ALL
				SELECT ISNULL(d.Rep2Id, h.Rep2Id) RepId
					, SUM(SIGN(h.TransType) * d.PriceExt) AS Sales
					, SUM(SIGN(h.TransType) * d.CostExt) AS COGS
					, SUM(SIGN(h.TransType) * (d.PriceExt - d.CostExt)) AS Profit 
					FROM dbo.tblArHistHeader h
					INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun and h.TransId = d.TransId
					WHERE h.VoidYn = 0 AND d.EntryNum >= 0 AND d.GrpId IS NULL AND ISNULL(d.Rep2Id, h.Rep2Id) IS NOT NULL
						AND ((@Timeframe = 1 AND (GLPeriod = @Period AND FiscalYear = @FiscalYear))
							OR (@Timeframe = 2 AND (GLPeriod <= @Period AND FiscalYear = @FiscalYear))
							OR (@Timeframe NOT IN (1, 2)))
					GROUP BY ISNULL(d.Rep2Id, h.Rep2Id)
				) h 
				ON r.SalesRepId = h.RepId 
		GROUP BY r.SalesRepId, r.[Name]
		ORDER BY CASE WHEN @returnValue = 'S' THEN SUM(Sales)  ELSE SUM(Profit) END DESC
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopSalesRepList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopSalesRepList_proc';


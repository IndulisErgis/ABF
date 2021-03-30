CREATE PROCEDURE [dbo].[trav_DbTopItemList_proc]
@Prec tinyint = 2, 
@RecReturn int =10,
@Wksdate datetime = null,
@Timeframe tinyint =0  -- 0 = All Time, 1 = PTD, 2 = YTD

AS
BEGIN TRY
	SET NOCOUNT ON

DECLARE  @Period int,@FiscalYear int

SELECT @FiscalYear = GlYear, @Period = GlPeriod 
FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate

Set RowCount @RecReturn
SELECT i.ItemId,i.Descr,SUM(ISNULL(Sales,0)) AS Sales
FROM dbo.tblInItem i 
							LEFT JOIN
							(
								SELECT ItemId,GLPeriod,SumYear,SUM(CASE TransType WHEN 3 THEN PriceExt ELSE -PriceExt END) AS Sales
								FROM dbo.tblInHistDetail 
								WHERE ((@Timeframe = 1 AND (GLPeriod = @Period AND SumYear = @FiscalYear))
								 OR (@Timeframe = 2 AND (GLPeriod <= @Period AND SumYear = @FiscalYear))
                              OR (@Timeframe NOT IN (1, 2)))
                              AND TransType IN(3,4)
                              GROUP BY ItemId,GLPeriod,SumYear
                              )h
                              ON i.ItemId = h.ItemId 
                                GROUP BY i.ItemId,i.Descr 
                              ORDER BY Sales Desc


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopItemList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopItemList_proc';


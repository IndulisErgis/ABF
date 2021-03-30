
CREATE PROCEDURE dbo.trav_DbTopCustomerList_proc
@Prec tinyint = 2, 
@Foreign bit = 0, 
@Profit bit = 0,  -- 0 = Sales, 1 = Profit
@Timeframe tinyint = 0, -- 0 = All Time, 1 = MTD, 2 = YTD
@noOfCusts int = 10,
@Wksdate datetime = null,
@SalesRepId pSalesRep, 
@returnValue nvarchar(10) = 'S' 

AS
BEGIN TRY
	SET NOCOUNT ON
	
	 DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate
	
	Set RowCount @noOfCusts
SELECT c.CustId, CustName, c.SalesRepId1, SUM(ISNULL(Sales, 0)) AS Sales, SUM(COGS) AS COGS,SUM(ISNULL(Profit, 0)) AS Profit,
  LEFT(Db_Name(), 3) CompId
		FROM dbo.tblArCust c
		 LEFT JOIN 
			(SELECT h.CustId, GLPeriod, FiscalYear, 
				SUM(CASE @Foreign WHEN 0 THEN (TaxSubtotal + NonTaxSubTotal) ELSE (TaxSubtotalFgn + NonTaxSubTotalFgn) END * SIGN(TransType)) AS Sales,
				SUM(CASE @Foreign  WHEN 0 THEN TotCost ELSE TotCostFgn END) As COGS, 
				SUM(((CASE @Foreign WHEN 0 THEN (TaxSubtotal + NonTaxSubTotal) ELSE (TaxSubtotalFgn + NonTaxSubTotalFgn) END )
				-( CASE @Foreign WHEN 0 THEN TotCost ELSE TotCostFgn END)) * SIGN(TransType)) AS Profit
				
				FROM dbo.tblArHistHeader h 
				WHERE ((@Timeframe = 1 AND (GLPeriod = @Period AND FiscalYear = @FiscalYear))
			       OR (@Timeframe = 2 AND (GLPeriod <= @Period AND FiscalYear = @FiscalYear))
			          OR (@Timeframe NOT IN (1, 2)))
                   AND VoidYn = 0
		GROUP BY h.CustId, GLPeriod, FiscalYear) h ON c.CustId = h.CustId
		WHERE (NULLIF(@SalesRepId, '') IS NULL OR c.SalesRepId1 = @SalesRepId) 
		GROUP BY c.CustId, CustName, c.SalesRepId1
		ORDER BY CASE WHEN @returnValue = 'P'  THEN SUM(Profit) ELSE SUM(Sales) END DESC 
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopCustomerList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopCustomerList_proc';


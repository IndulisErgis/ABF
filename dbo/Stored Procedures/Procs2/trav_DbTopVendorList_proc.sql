
CREATE PROCEDURE [dbo].[trav_DbTopVendorList_proc]
@Foreign bit = 0, 
@Timeframe tinyint = 0, -- 0 = All Time, 1 = PTD, 2 = YTD
@RecReturn int = 10 ,
@Wksdate datetime = null

AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE @FiscalYear smallint, @Period smallint
	SELECT @FiscalYear = GlYear, @Period = GlPeriod 
	FROM dbo.tblSmPeriodConversion WHERE @WksDate BETWEEN BegDate AND EndDate
      --set the number of records to return
      SET ROWCOUNT @RecReturn
      
      SELECT v.VendorID, v.[Name] AS VendorName
            , ISNULL(Purchases, 0) AS Purchases 
      FROM dbo.tblApVendor v 
            LEFT JOIN 
                  (
                   SELECT VendorId
                              , SUM(CASE @Foreign WHEN 0 THEN Purch ELSE PurchFgn END) AS Purchases
                        FROM dbo.tblApVendorHistDetail 
                        WHERE ((@Timeframe = 1 AND (GLPeriod = @Period AND FiscalYear = @FiscalYear))
                              OR (@Timeframe = 2 AND (GLPeriod <= @Period AND FiscalYear = @FiscalYear))
                              OR (@Timeframe NOT IN (1, 2)))
                        GROUP BY VendorID
                  ) h 
                  ON v.VendorId = h.VendorId 
      ORDER BY Purchases DESC

END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopVendorList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DbTopVendorList_proc';


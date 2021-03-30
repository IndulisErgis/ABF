
CREATE PROCEDURE dbo.trav_ArSalesRepList_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT r.SalesRepID, r.[Name], r.Addr1, r.Addr2, r.City, r.Region, r.Country, r.PostalCode, r.IntlPrefix, 
		r.Phone, r.Fax, r.EmplId, r.RunCode, r.CommRate, r.PctOf, r.BasedOn, r.PayOnLineItems, r.PayOnSalesTax, 
		r.PayOnFreight, r.PayOnMisc, r.PTDSales, r.YTDSales, r.LastSalesDate, r.Email, r.Internet, r.PayVia, 
		r.EarnCode, r.VendorId
	FROM #tmpSalesRepList t INNER JOIN dbo.tblArSalesRep r (NOLOCK) ON t.SalesRepId = r.SalesRepID

	SELECT m.Id, m.SalesRepID, m.CommType, m.RefID, m.CommRate
	FROM #tmpSalesRepList t INNER JOIN dbo.tblArSalesRepComm m  (NOLOCK) ON t.SalesRepId = m.SalesRepID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesRepList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSalesRepList_proc';


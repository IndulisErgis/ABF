
CREATE PROCEDURE dbo.trav_SoBookedSalesReport_proc 
@OrderDateFrom datetime = NULL,
@OrderDateThru datetime = NULL,
@SortBy tinyint = 0, --0,Customer ID; 1,Sales Category; 2,Sales Rep ID; 3,Territory ID;
@CurrencyPrecision tinyint = 2
AS
--PET:240064
SET NOCOUNT ON
BEGIN TRY
	SELECT TransId, TransDate, EntryNum, ItemId, GrpId1, GrpId1Descr, SUM(ExtPrice) AS ExtPrice, SUM(ExtCost) AS ExtCost, SUM(ExtPrice) - SUM(ExtCost) AS Profit
	FROM 
	(
	SELECT h.TransId, d.ItemId, ISNULL(SIGN(h.TransType) * ROUND(d.QtyOrdSell *  d.UnitPriceSell,@CurrencyPrecision),0) AS ExtPrice, 
		ISNULL(SIGN(h.TransType) * ROUND(d.QtyOrdSell *  d.UnitCostSell,@CurrencyPrecision),0) AS ExtCost,
		h.TransDate, d.EntryNum, 
		ISNULL(CASE @SortBy WHEN 0 THEN h.CustId WHEN 1 THEN d.CatId WHEN 2 THEN ISNULL(d.Rep1Id, h.Rep1Id)  WHEN 3 THEN a.TerrId END,'') AS GrpId1, 
		ISNULL(CASE @SortBy WHEN 0 THEN a.CustName	WHEN 1 THEN i.Descr	WHEN 2 THEN s.[Name] END,'') AS GrpId1Descr 
	FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransID = d.TransID 
		INNER JOIN #tmpTransDetailList t ON d.TransId = t.TransId AND d.EntryNum = t.EntryNum
		LEFT JOIN dbo.tblInSalesCat i ON i.SalesCat = d.CatId 
		LEFT JOIN dbo.tblArCust a ON a.CustId = h.CustId 
		LEFT JOIN dbo.tblArSalesRep s ON s.SalesRepID = ISNULL(d.Rep1Id, h.Rep1Id) 
	WHERE d.GrpId IS NULL AND h.TransType <> 2 AND h.VoidYn = 0 AND (@OrderDateFrom IS NULL OR h.TransDate >= @OrderDateFrom) AND
		(@OrderDateThru IS NULL OR h.TransDate <= @OrderDateThru)
	UNION ALL
	SELECT h.TransId, d.PartId AS ItemId, ISNULL(SIGN(h.TransType) * ROUND(d.QtyShipSell *  d.UnitPriceSell,@CurrencyPrecision),0) AS ExtPrice, 
		ISNULL(SIGN(h.TransType) * ROUND(d.QtyShipSell *  d.UnitCostSell,@CurrencyPrecision),0) AS ExtCost, 
		h.OrderDate, d.EntryNum, 
		ISNULL(CASE @SortBy WHEN 0 THEN h.CustId WHEN 1 THEN d.CatId WHEN 2 THEN ISNULL(d.Rep1Id, h.Rep1Id)  WHEN 3 THEN a.TerrId END,'') AS GrpId1, 
		ISNULL(CASE @SortBy WHEN 0 THEN a.CustName	WHEN 1 THEN i.Descr	WHEN 2 THEN s.[Name] END,'') AS GrpId1Descr 
	FROM dbo.tblArHistHeader h INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransID = d.TransID 
		INNER JOIN #tmpHistoryDetailList t ON d.PostRun = t.PostRun AND d.TransId = t.TransId AND d.EntryNum = t.EntryNum
		LEFT JOIN dbo.tblInSalesCat i ON i.SalesCat = d.CatId 
		LEFT JOIN dbo.tblArCust a ON a.CustId = h.CustId 
		LEFT JOIN dbo.tblArSalesRep s ON s.SalesRepID = ISNULL(d.Rep1Id, h.Rep1Id)  
	WHERE d.GrpId IS NULL AND h.VoidYn = 0 AND (@OrderDateFrom IS NULL OR h.OrderDate >= @OrderDateFrom) AND
		(@OrderDateThru IS NULL OR h.OrderDate <= @OrderDateThru) AND 
		d.EntryNum > 0
	) BookedSale
	GROUP BY TransId, TransDate, EntryNum, ItemId, GrpId1, GrpId1Descr
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBookedSalesReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoBookedSalesReport_proc';


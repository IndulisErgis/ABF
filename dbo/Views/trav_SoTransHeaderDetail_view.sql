
CREATE VIEW dbo.trav_SoTransHeaderDetail_view
AS

--PET:http://webfront:801/view.php?id=238166

	SELECT h.BatchId,h.SoldToID, h.ShipToID, h.InvcNum, h.InvcDate, h.TransId, h.CustId, 
		h.Rep1Id, h.Rep2Id, h.GLPeriod, h.FiscalYear, h.CustPONum, h.DistCode, h.CurrencyID,  
		d.EntryNum, d.LocId, d.ItemId, d.ItemJob, d.CatId, d.JobId, d.GLAcctSales,
		c.CustName, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode, c.DistCode AS CustDistCode, c.TerrId, 
		c.CustLevel, c.Status, i.Descr, i.ProductLine, i.SalesCat, i.PriceID, i.TaxClass, 
		ISNULL(d.Rep1Id, h.Rep1Id) AS Rep1IdDetail, ISNULL(d.Rep2Id, h.Rep2Id) AS Rep2IdDetail 
	FROM dbo.tblSoTransHeader h LEFT JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId
		INNER JOIN dbo.tblArCust c ON h.CustId = c.CustId 
		LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoTransHeaderDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoTransHeaderDetail_view';


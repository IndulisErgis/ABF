
CREATE VIEW dbo.trav_ArHistHeaderDetail_view
AS
	SELECT h.PostRun,h.BatchId,h.SoldToID, h.ShipToID, h.InvcNum, h.InvcDate, h.TransId, h.CustId, 
		h.Rep1Id, h.Rep2Id, h.GLPeriod, h.FiscalYear, h.CustPONum, h.DistCode, h.CurrencyID,  
		d.EntryNum, d.WhseId, d.PartId, d.ItemJob, d.PartType, d.CatId, d.JobId, d.GLAcctSales,
		c.CustName, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode, c.DistCode AS CustDistCode, c.TerrId, 
		c.CustLevel, c.Status
	FROM dbo.tblArHistHeader h INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId
		LEFT JOIN dbo.tblArCust c ON h.CustId = c.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArHistHeaderDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArHistHeaderDetail_view';


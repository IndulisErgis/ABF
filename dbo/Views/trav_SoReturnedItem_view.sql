
CREATE VIEW dbo.trav_SoReturnedItem_view
AS
	SELECT r.Counter, r.Status, r.ResCode, r.RMANumber, r.CustID, r.TransId, r.ItemId, 
		r.LocId, r.ExtLocAID, r.ExtLocBID, r.EntryDate, r.TransDate, r.Units, 
		r.LotNum, r.SerNum, r.GLAcctCOGS, r.GLAcctInv, r.Notes, i.Descr, 
		i.ProductLine, i.SalesCat, i.PriceID, i.TaxClass
	FROM dbo.tblSoReturnedItem r LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoReturnedItem_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoReturnedItem_view';


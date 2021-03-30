
CREATE VIEW dbo.trav_InSerilizedHistory_view
AS
SELECT d.ItemId, d.LocId, d.ItemType, d.LottedYN, d.TransType, d.SumYear, d.SumPeriod, 
	d.GLPeriod, d.AppId, d.BatchId, d.TransId, d.RefId, d.SrceID, d.TransDate, d.Uom, d.UomBase, 
	d.Source, d.DropShipYn, s.SeqNum, s.LotNum, s.SerNum, s.InvcNum, s.DateOrder, s.DateInvc, 
	s.DateRcpt, s.DateShip, s.Cmnt, i.Descr, i.ProductLine, i.SalesCat, i.PriceId, i.TaxClass
FROM dbo.tblInHistDetail d INNER JOIN dbo.tblInHistSer s ON d.HistSeqNum = s.HistSeqNum
	LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InSerilizedHistory_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InSerilizedHistory_view';


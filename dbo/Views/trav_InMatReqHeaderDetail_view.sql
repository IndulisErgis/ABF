
CREATE VIEW dbo.trav_InMatReqHeaderDetail_view
AS
SELECT h.TransId, h.ReqNum, h.ReqstdBy, h.ReqType, d.LineNum, d.LocId, d.ItemId, h.ShipToId,
	i.Descr, i.ProductLine, i.SalesCat, i.PriceId, i.TaxClass
FROM dbo.tblInMatReqHeader h INNER JOIN dbo.tblInMatReqDetail d ON h.TransId = d.TransId
	INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InMatReqHeaderDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_InMatReqHeaderDetail_view';


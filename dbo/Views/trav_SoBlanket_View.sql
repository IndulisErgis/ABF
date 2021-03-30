
create VIEW [dbo].[trav_SoBlanket_View]
AS
	SELECT  h.BlanketId,h.Rep1Id,h.Rep2Id,c.Status,i.TaxClass,c.TerrId,h.SoldToId,h.ShipToId,d.CatId,d.GLAcctSales,
	i.ProductLine,h.CustPONum,h.LocId,d.ItemId,c.GroupCode,h.DistCode,d.Descr,c.CustName,c.CustLevel,
	h.CurrencyId,h.ContractDate,c.ClassId,h.BlanketType,h.BlanketStatus,h.CustId,c.AcctType,c.PriceCode as CustPriceId, i.PriceId as ItemPriceId FROM dbo.tblSoSaleBlanket h  inner join dbo.tblSoSaleBlanketDetail d on d.BlanketRef = h.BlanketRef
			INNER JOIN dbo.tblArCust c ON h.CustId = c.CustId 
		LEFT JOIN dbo.tblInItem i ON d.ItemId = i.ItemId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoBlanket_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_SoBlanket_View';


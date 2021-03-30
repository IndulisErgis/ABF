
CREATE VIEW dbo.pvtSoRecurring
AS
SELECT dbo.tblArRecurHeader.RecurID, dbo.tblArRecurHeader.StartingDate, dbo.tblArRecurHeader.EndingDate
	, dbo.tblArRecurHeader.CustId, dbo.tblArRecurDetail.EntryNum
	, dbo.tblArRecurDetail.ItemId as [Item$]
	, dbo.tblArRecurDetail.Units AS [UnitsSell], dbo.tblArRecurDetail.Quantity AS [QtyOrdSell]
	, dbo.tblArRecurDetail.UnitPrice AS [UnitPriceSell], dbo.tblArRecurDetail.UnitCost AS [UnitCostSell]
	, dbo.tblArCust.CustName
FROM dbo.tblArRecurHeader 
INNER JOIN dbo.tblArRecurDetail ON dbo.tblArRecurHeader.RecurID = dbo.tblArRecurDetail.RecurID 
INNER JOIN dbo.tblArCust ON dbo.tblArRecurHeader.CustId = dbo.tblArCust.CustId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoRecurring';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoRecurring';


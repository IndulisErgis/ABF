
CREATE  VIEW dbo.pvtArSalesJournal
AS
SELECT dbo.tblArTransHeader.BatchId
	, CASE WHEN dbo.tblArTransHeader.TransType = 1 THEN 'Invoice' ELSE 'Credit' END AS [TransType$]
	, dbo.tblArTransHeader.TransId, dbo.tblArTransDetail.EntryNum, dbo.tblArTransHeader.CustId, dbo.tblArCust.BillToId
	, CASE WHEN dbo.tblArTransDetail.ItemJob = 0 THEN dbo.tblArTransDetail.PartId ELSE dbo.tblArTransDetail.JobId END AS [Item$]
	, dbo.tblArTransHeader.InvcNum, dbo.tblArTransDetail.QtyOrdSell, dbo.tblArTransDetail.QtyShipSell
	, dbo.tblArTransDetail.UnitPriceSell, dbo.tblArTransDetail.UnitCostSell 
FROM dbo.tblArTransHeader 
INNER JOIN dbo.tblArTransDetail ON dbo.tblArTransHeader.TransId = dbo.tblArTransDetail.TransID 
INNER JOIN dbo.tblArCust ON dbo.tblArTransHeader.CustId = dbo.tblArCust.CustId
WHERE dbo.tblArTransHeader.VoidYn = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArSalesJournal';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArSalesJournal';


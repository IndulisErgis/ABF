
CREATE  VIEW dbo.pvtSoSalesJournal
AS
SELECT dbo.tblSoTransHeader.TransId, dbo.tblSoTransHeader.BatchId
	, CASE dbo.tblSoTransHeader.TransType 
		WHEN 1 THEN (CASE WHEN dbo.tblSoTransHeader.Layaway = 1 THEN 'Layaway' ELSE 'Invoice' END) 
		WHEN 2 THEN 'Price Quote' 
		WHEN 3 THEN 'Backordered' 
		WHEN 4 THEN 'Verified' 
		WHEN 9 THEN 'New' 
		WHEN 5 THEN 'Picked' 
		WHEN -1 THEN 'Credit Memo' 
		WHEN -2 THEN 'RMA'
		END AS [TransType]
	, dbo.tblSoTransHeader.CustId, dbo.tblSoTransHeader.SoldToId, dbo.tblSoTransDetail.EntryNum
	, CASE WHEN dbo.tblSoTransDetail.ItemJob = 0 THEN dbo.tblSoTransDetail.ItemId ELSE dbo.tblSoTransDetail.JobId END AS [Item$]
	, dbo.tblSoTransDetail.Descr, dbo.tblSoTransDetail.UnitsSell, dbo.tblSoTransDetail.QtyOrdSell, dbo.tblSoTransDetail.QtyShipSell
	, dbo.tblSoTransDetail.QtyBackordSell, dbo.tblSoTransDetail.UnitCostSell, dbo.tblSoTransDetail.UnitPriceSell 
FROM dbo.tblSoTransHeader INNER JOIN dbo.tblSoTransDetail ON dbo.tblSoTransHeader.TransId = dbo.tblSoTransDetail.TransID 
WHERE dbo.tblSoTransDetail.[Status] = 0 AND VoidYn = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoSalesJournal';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSoSalesJournal';


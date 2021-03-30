
CREATE VIEW dbo.pvtArDetSalesHist
AS
SELECT dbo.tblArHistHeader.CustId, dbo.tblArHistHeader.SoldToId, dbo.tblArHistHeader.Rep1Id, dbo.tblArHistHeader.Rep2Id
	, dbo.tblArHistHeader.FiscalYear, dbo.tblArHistHeader.GLPeriod, dbo.tblArHistHeader.InvcNum, dbo.tblArHistHeader.InvcDate
	, CASE WHEN dbo.tblArHistDetail.ItemJob = 0 THEN dbo.tblArHistDetail.PartId ELSE dbo.tblArHistDetail.JobId END AS [Item$]
	, dbo.tblArHistDetail.[Desc], dbo.tblArHistDetail.QtyShipSell * dbo.tblArHistHeader.TransType AS QtyShipSell
	, dbo.tblArHistDetail.UnitPriceSell 
FROM dbo.tblArHistHeader INNER JOIN dbo.tblArHistDetail ON (dbo.tblArHistHeader.postrun = dbo.tblArHistDetail.postrun) 
	AND (dbo.tblArHistHeader.TransId = dbo.tblArHistDetail.TransId)
WHERE dbo.tblArHistHeader.VoidYn = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArDetSalesHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtArDetSalesHist';


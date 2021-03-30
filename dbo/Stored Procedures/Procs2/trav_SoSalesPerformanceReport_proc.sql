
CREATE PROCEDURE dbo.trav_SoSalesPerformanceReport_proc 
@QuantityVariance pDecimal = 0,
@DateVariance int = 0
AS
SET NOCOUNT ON
BEGIN TRY

SELECT d.QtyOrdSell, d.QtyShipSell, h.CustId, c.CustName, h.TransId, d.PartId AS ItemId,
	d.[Desc] AS ItemDescr, d.WhseId AS LocId, l.Descr AS LocDescr, ISNULL(d.ReqShipDate, h.ReqShipDate) AS ReqShipDate, 
	ISNULL(d.ActShipDate, h.ShipDate) AS ActShipDate, CASE WHEN d.GrpId IS NULL THEN d.LineSeq ELSE k.LineSeq END EntryNum, 
	CASE WHEN d.GrpId IS NULL THEN 0 ELSE d.LineSeq END GrpId,
	CASE WHEN d.QtyOrdSell <> 0 THEN (((d.QtyShipSell - d.QtyOrdSell) / d.QtyOrdSell) * 100) ELSE 0 END AS QtyVariance, 
	DATEDIFF (dd, (ISNULL(d.ReqShipDate, h.ReqShipDate)), (ISNULL(d.ActShipDate, h.ShipDate))) AS DateVariance 
FROM dbo.tblArHistHeader h INNER JOIN dbo.tblArHistDetail d ON h.PostRun = d.PostRun AND h.TransId = d.TransId
	INNER JOIN #tmpHistoryDetailList t ON d.PostRun = t.PostRun AND d.TransId = t.TransId AND d.EntryNum = t.EntryNum
	LEFT JOIN dbo.tblArCust c ON c.CustId = h.CustId 
	LEFT JOIN dbo.tblInLoc l ON l.LocId = d.WhseId 
	LEFT JOIN dbo.tblArHistDetail k ON d.PostRun = k.PostRun AND d.TransId = k.TransId AND d.GrpId = k.EntryNum
WHERE h.VoidYn = 0 AND d.EntryNum > 0 AND ABS(CASE WHEN d.QtyOrdSell <> 0 THEN (((d.QtyShipSell - d.QtyOrdSell) / d.QtyOrdSell) * 100) ELSE 0 END) >= @QuantityVariance
	AND ABS(DATEDIFF(dd, (ISNULL(d.ReqShipDate, h.ReqShipDate)), (ISNULL(d.ActShipDate, h.ShipDate)))) >= @DateVariance

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoSalesPerformanceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoSalesPerformanceReport_proc';


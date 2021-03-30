
CREATE VIEW dbo.pvtMpFinishedGoodLotNumberHistory
AS

SELECT x.LotNum AS 'FG Lot No', m.ComponentID AS 'RM Component ID', m.LocID AS 'RM Location ID'
	, m.Qty AS 'RM Qty', r.OrderNo AS 'Order No', r.ReleaseNo AS 'Release No', r.LotNum AS 'RM Lot No'
	, o.CustId AS 'Customer ID', o.PurchaseOrder AS 'Customer PO No', o.SalesOrder AS 'Sales Order No'
	, s.SerNum AS 'RM Serial No' 
FROM dbo.tblMpHistoryOrderReleases o 
	INNER JOIN 
			(
				SELECT w.OrderNo, w.ReleaseNo, l.LotNum, z.PostRun, z.TransId 
				FROM dbo.tblMpHistoryOrderReleases w 
					INNER JOIN dbo.tblMpHistoryRequirements z 
						ON w.PostRun = z.PostRun AND w.ReleaseId = z.ReleaseId
					LEFT JOIN dbo.tblMpHistoryMatlDtlExt l 
						ON z.PostRun = l.PostRun AND z.TransId = l.TransId
				WHERE z.Type <> 0
			) r 
		ON r.OrderNo = o.OrderNo AND r.ReleaseNo = o.ReleaseNo 
	INNER JOIN 
			(
				SELECT p.OrderNo, p.ReleaseNo, u.LotNum, y.PostRun, y.TransId 
				FROM dbo.tblMpHistoryOrderReleases p 
					INNER JOIN dbo.tblMpHistoryRequirements y 
						ON p.PostRun = y.PostRun AND p.ReleaseId = y.ReleaseId
					INNER JOIN dbo.tblMpHistoryMatlDtlExt u 
						ON y.PostRun = u.PostRun AND y.TransId = u.TransId
				WHERE y.Type = 0
			) x 
		ON x.OrderNo = o.OrderNo AND x.ReleaseNo = o.ReleaseNo 
	INNER JOIN dbo.tblMpHistoryMatlDtl m ON m.PostRun = r.PostRun AND m.TransId = r.TransId 
	LEFT OUTER JOIN dbo.tblMpHistoryMatlSer s ON s.PostRun = m.PostRun AND s.TransId = m.TransId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpFinishedGoodLotNumberHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpFinishedGoodLotNumberHistory';


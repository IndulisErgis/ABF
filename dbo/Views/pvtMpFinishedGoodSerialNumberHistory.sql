
CREATE VIEW dbo.pvtMpFinishedGoodSerialNumberHistory
AS

SELECT x.SerNum AS 'FG Serial No', m.ComponentID AS 'RM Component ID', m.LocID AS 'RM Location ID'
	, m.Qty AS 'RM Qty', r.OrderNo AS 'Order No', r.SerNum AS 'RM Serial No', o.CustId AS 'Customer ID'
	, o.PurchaseOrder AS 'Customer PO No', o.SalesOrder AS 'Sales Order No', l.LotNum AS 'RM Lot No'
	, l.QtyFilled AS 'RM Lot Qty' 
FROM dbo.tblMpHistoryOrderReleases o 
	INNER JOIN 
			(
				SELECT w.OrderNo, w.ReleaseNo, s.SerNum, z.PostRun, z.TransId 
				FROM dbo.tblMpHistoryOrderReleases w 
					INNER JOIN dbo.tblMpHistoryRequirements z 
						ON w.PostRun = z.PostRun AND w.ReleaseId = z.ReleaseId
					LEFT JOIN dbo.tblMpHistoryMatlSer s 
						ON z.PostRun = s.PostRun AND z.TransId = s.TransId
				WHERE z.Type <> 0
			) r 
		ON r.OrderNo = o.OrderNo AND r.ReleaseNo = o.ReleaseNo 
	INNER JOIN 
			(
				SELECT p.OrderNo, p.ReleaseNo, u.SerNum, y.PostRun, y.TransId 
				FROM dbo.tblMpHistoryOrderReleases p 
					INNER JOIN dbo.tblMpHistoryRequirements y 
						ON p.PostRun = y.PostRun AND p.ReleaseId = y.ReleaseId
					INNER JOIN dbo.tblMpHistoryMatlSer u 
						ON y.PostRun = u.PostRun AND y.TransId = u.TransId
				WHERE y.Type = 0
			) x 
		ON x.OrderNo = o.OrderNo AND x.ReleaseNo = o.ReleaseNo 
	INNER JOIN dbo.tblMpHistoryMatlDtl m ON m.PostRun = r.PostRun AND m.TransId = r.TransId 
	LEFT OUTER JOIN dbo.tblMpHistoryMatlDtlExt l ON l.PostRun = m.PostRun AND l.TransId = m.TransId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpFinishedGoodSerialNumberHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpFinishedGoodSerialNumberHistory';


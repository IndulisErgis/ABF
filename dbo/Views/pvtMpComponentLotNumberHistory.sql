
CREATE VIEW dbo.pvtMpComponentLotNumberHistory
AS

SELECT l.LotNum AS 'RM Lot No', m.ComponentId as 'RM Component ID',x.LotNum AS 'FG Lot No'
	, o.AssemblyId as 'FG Assembly ID',o.OrderNo as 'Order No', o.ReleaseNo as 'Release No'
	, o.CustId as 'Customer ID', o.SalesOrder as 'Sales Order No', o.PurchaseOrder as 'Customer PO No'
	, m.TransDate as 'Transaction Date', s.SerNum as 'Serial No' 
FROM dbo.tblMpHistoryMatlDtlExt l 
	INNER JOIN 
			(
				SELECT w.OrderNo, w.ReleaseNo, z.PostRun, z.TransId 
				FROM dbo.tblMpHistoryOrderReleases w 
					INNER JOIN dbo.tblMpHistoryRequirements z 
						ON w.PostRun = z.PostRun AND w.ReleaseId = z.ReleaseId
				WHERE z.Type <> 0
			) r 
		ON r.PostRun = l.PostRun AND r.TransId = l.TransId
	INNER JOIN dbo.tblMpHistoryMatlDtl m ON m.PostRun = r.PostRun AND m.TransId = r.TransId 
	INNER JOIN dbo.tblMpHistoryOrderReleases o ON o.OrderNo = r.OrderNo AND o.ReleaseNo = r.ReleaseNo 
	INNER JOIN 
			(
				SELECT p.OrderNo, p.ReleaseNo, k.PostRun, k.TransId 
				FROM dbo.tblMpHistoryOrderReleases p 
					INNER JOIN dbo.tblMpHistoryRequirements k 
						ON p.PostRun = k.PostRun AND p.ReleaseId = k.ReleaseId
				WHERE k.Type = 0
			) y 
		ON y.OrderNo = o.OrderNo AND y.ReleaseNo = o.ReleaseNo 
	LEFT OUTER JOIN dbo.tblMpHistoryMatlDtlExt x ON x.PostRun = y.PostRun AND x.TransId = y.TransId
	LEFT OUTER JOIN dbo.tblMpHistoryMatlSer s ON s.PostRun = y.PostRun AND s.TransId = y.TransId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpComponentLotNumberHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpComponentLotNumberHistory';


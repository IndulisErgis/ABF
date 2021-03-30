
CREATE VIEW dbo.pvtMpMaterialUsage
AS

SELECT x.OrderNo AS 'Order No', x.ReleaseNo AS 'Release No', x.ReqID AS 'Req ID'
	, RIGHT(REPLICATE('0',10) + CAST(x.ReqId AS nvarchar), 10) AS ReqIdSort, x.ComponentID AS 'Component ID'
	, x.LocID AS 'Location ID', x.EstQtyRequired AS 'Est Qty', x.ActualQtyUsed AS 'Act Qty', x.UOM AS 'Unit'
	, (x.EstQtyRequired - x.ActualQtyUsed) AS 'Variance'
	, CASE o.Status 
		WHEN 0 THEN 'New' 
		WHEN 1 THEN 'Planned' 
		WHEN 2 THEN 'Firm Planned' 
		WHEN 3 THEN 'Released' 
		WHEN 4 THEN 'In Process' 
		WHEN 5 THEN 'Production Hold' 
		WHEN 6 THEN 'Completed' 
		ELSE '(NA)' END AS [Status] 
FROM 
	(
		SELECT o.OrderNo, o.ReleaseNo, r.ReqID, s.ComponentID, s.LocID, s.EstQtyRequired, s.UOM
			, ISNULL(d.ActualQtyUsed / us.ConvFactor, 0) ActualQtyUsed 
FROM dbo.tblMpOrderReleases o 
	INNER JOIN dbo.tblMpRequirements r ON o.Id = r.ReleaseId 
	INNER JOIN dbo.tblMpMatlSum s ON r.TransId = s.TransId 
			LEFT JOIN 
					(
						SELECT s1.TransID, SUM(d1.Qty * ud.ConvFactor) AS ActualQtyUsed 
						FROM dbo.tblMpMatlSum s1 
							INNER JOIN dbo.tblMpMatlDtl d1 
								ON s1.TransID = d1.TransID 
LEFT JOIN dbo.tblInItemUom ud ON d1.ComponentId = ud.ItemId AND d1.UOM = ud.Uom
						GROUP BY s1.TransID
					) d 
				ON s.TransID = d.TransID 
LEFT JOIN dbo.tblInItemUom us ON s.ComponentId = us.ItemId AND s.UOM = us.Uom
WHERE s.ComponentType <> 0 AND s.ComponentType <> 2) x 
	JOIN dbo.tblMpOrderReleases o ON x.OrderNo = o.OrderNo AND x.ReleaseNo = o.ReleaseNo

UNION

SELECT x.OrderNo AS 'Order No', x.ReleaseNo AS 'Release No', x.ReqID AS 'Req ID'
	, RIGHT(REPLICATE('0',10) + CAST(x.ReqId AS nvarchar), 10) AS ReqIdSort, x.ComponentID AS 'Component ID'
	, x.LocID AS 'Location ID', x.EstQtyRequired AS 'Est Qty', x.ActualQtyUsed AS 'Act Qty', x.UOM AS 'Unit'
	, (x.EstQtyRequired - x.ActualQtyUsed) AS 'Variance'
	, CASE o.Status 
		WHEN 0 THEN 'New' 
		WHEN 1 THEN 'Planned' 
		WHEN 2 THEN 'Firm Planned' 
		WHEN 3 THEN 'Released' 
		WHEN 4 THEN 'In Process' 
		WHEN 5 THEN 'Production Hold' 
		WHEN 6 THEN 'Completed' 
		ELSE '(NA)' END AS [Status] 
FROM 
	(
		SELECT o.OrderNo, o.ReleaseNo, r.ReqID, s.ComponentID, s.LocID, s.EstQtyRequired, s.UOM
			, ISNULL(d.ActualQtyUsed / s.ConvFactor, 0) ActualQtyUsed 
FROM dbo.tblMpHistoryOrderReleases o 
	INNER JOIN dbo.tblMpHistoryRequirements r ON o.PostRun = r.PostRun AND o.ReleaseId = r.ReleaseId 
	INNER JOIN dbo.tblMpHistoryMatlSum s ON r.PostRun = s.PostRun AND r.TransId = s.TransId 
			LEFT JOIN 
					(
						SELECT s1.PostRun, s1.TransId, SUM(d1.Qty * d1.ConvFactor) AS ActualQtyUsed 
						FROM dbo.tblMpHistoryMatlSum s1 
							INNER JOIN dbo.tblMpHistoryMatlDtl d1 
								ON s1.PostRun = d1.PostRun AND s1.TransID = d1.TransID 
						GROUP BY s1.PostRun, s1.TransID
					) d 
				ON s.PostRun = d.PostRun AND s.TransID = d.TransID 
WHERE s.ComponentType <> 0 AND s.ComponentType <> 2) x 
	JOIN dbo.tblMpHistoryOrderReleases o ON x.OrderNo = o.OrderNo AND x.ReleaseNo = o.ReleaseNo
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpMaterialUsage';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpMaterialUsage';


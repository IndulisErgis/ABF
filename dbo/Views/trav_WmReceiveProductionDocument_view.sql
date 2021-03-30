
CREATE VIEW dbo.trav_WmReceiveProductionDocument_view
AS	
	SELECT rel.OrderNo, rel.ReleaseNo
	FROM dbo.tblMpOrderReleases rel 
	INNER JOIN  dbo.tblMpRequirements req ON rel.Id=req.ReleaseId 
	INNER JOIN dbo.tblMpMatlSum s ON req.TransId =s.TransId 
	WHERE rel.[Status] <> 6 AND ((s.ComponentType = 5 AND s.[Status] <> 6) OR s.ComponentType = 0)
	GROUP BY rel.OrderNo, rel.ReleaseNo
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmReceiveProductionDocument_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmReceiveProductionDocument_view';


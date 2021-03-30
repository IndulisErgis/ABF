
CREATE VIEW dbo.pvtMpOperationsStatus
AS

SELECT TOP 100 PERCENT o.OrderNo AS 'Order No', o.releaseNo AS 'Release No', r.ReqId AS 'Req ID'
	, t.RequiredDate AS 'Date Required'
	, CASE WHEN t.Status = '4' AND d.TransId IS NULL THEN 'Incomplete' 
		WHEN t.Status = '4' THEN 'Started' 
		WHEN t.Status = '5' THEN 'On Hold' ELSE 'Completed' END AS 'Status'
	, r.ParentId AS 'Parent ID', r.IndLevel AS 'Ind Level', r.Step, r.Description 
FROM dbo.tblMpTimeSum t 
	INNER JOIN dbo.tblMpRequirements r ON r.TransId = t.TransId 
	INNER JOIN dbo.tblMpOrderReleases o ON o.Id = r.ReleaseId 
	LEFT JOIN (SELECT TransID FROM dbo.tblMpTimeDtl GROUP BY TransID) d ON d.TransId = r.TransId 
ORDER BY o.OrderNo, o.ReleaseNo, r.IndLevel * -1, r.ParentId * -1, r.Step
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpOperationsStatus';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpOperationsStatus';


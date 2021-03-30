
CREATE VIEW dbo.pvtMpProductionOrderDetail
AS

SELECT h.OrderNo AS 'Order No', h.AssemblyID AS 'Assembly ID', h.RevisionNo AS 'Revision No'
	, a.[Description], h.LocID AS 'Location ID', ISNULL(h.Planner,'(NA)') AS Planner
	, d.ReleaseNo AS 'Release No', d.Routing
	, CASE d.Status 
		WHEN 0 THEN 'New' 
		WHEN 1 THEN 'Planned' 
		WHEN 2 THEN 'Firm Planned' 
		WHEN 3 THEN 'Released' 
		WHEN 4 THEN 'In Process' 
		WHEN 5 THEN 'Production Hold' 
		WHEN 6 THEN 'Completed' 
		ELSE '(NA)' END AS [Status]
	, d.EstStartDate AS 'Est Start Date', d.EstCompletionDate AS 'Est Finish Date'
	, ISNULL(d.CustID,'(NA)') AS 'Customer ID', d.UOM AS 'Unit', d.Qty
	, CASE d.OrderSource 
		WHEN 0 THEN 'Manual' 
		WHEN 1 THEN 'Imported' 
		WHEN 2 THEN 'Generated' 
		ELSE '(NA)' END AS 'Order Source'
	, d.OrderCode AS 'Order Code' 
FROM dbo.tblMpOrder h 
	INNER JOIN dbo.tblMpOrderReleases d ON h.OrderNo = d.OrderNo 
	LEFT JOIN dbo.tblMbAssemblyHeader a ON h.AssemblyID = a.AssemblyID AND h.RevisionNo = a.RevisionNo
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpProductionOrderDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpProductionOrderDetail';


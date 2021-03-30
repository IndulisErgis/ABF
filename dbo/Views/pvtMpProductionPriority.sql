
CREATE VIEW dbo.pvtMpProductionPriority
AS

SELECT TOP 100 PERCENT o.OrderNo AS 'Order No', o.AssemblyId AS 'Assembly ID', o.RevisionNo AS 'Revision No'
	, o.LocID AS 'Location ID', o.Planner
	, CASE r.Status 
		WHEN 0 THEN 'New' 
		WHEN 1 THEN 'Planned' 
		WHEN 2 THEN 'Firm Planned' 
		WHEN 3 THEN 'Released' 
		WHEN 4 THEN 'In Process' 
		WHEN 5 THEN 'Production Hold' 
		WHEN 6 THEN 'Completed' 
		ELSE '(NA)' END AS [Status]
	, r.CustId AS 'Customer ID', r.SalesOrder AS 'Sales Order No'
	, r.PurchaseOrder AS 'Customer PO No', r.EstStartDate AS 'Est Start Date', r.EstCompletionDate AS 'Est Finish Date'
	, r.Priority AS 'Priority', r.OrderCode AS 'Order Code', r.Qty, r.UOM AS 'Unit'
	, CASE r.OrderSource 
		WHEN 0 THEN 'Manual' 
		WHEN 1 THEN 'Imported' 
		WHEN 2 THEN 'Generated' 
		ELSE '(NA)' END AS 'Order Source'
	, r.Notes 
FROM dbo.tblMpOrder o 
	INNER JOIN dbo.tblMpOrderReleases r ON r.OrderNo = o.OrderNo 
ORDER BY r.Priority * - 1, r.EstStartDate
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpProductionPriority';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtMpProductionPriority';


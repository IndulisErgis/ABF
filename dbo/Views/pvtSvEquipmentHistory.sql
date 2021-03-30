
CREATE VIEW dbo.pvtSvEquipmentHistory
AS

SELECT o.WorkOrderNo AS [Order No]
	, o.CustID AS [Customer ID]
	, c.CustName AS [Customer Name]
	, o.OrderDate AS [Order Date]
	, e.EquipmentNo AS [Equipment ID]
	, d.EquipmentDescription AS [Equipment Desc]
	, CASE t.TransType 
		WHEN 0 THEN 'Labor' 
		WHEN 1 THEN 'Part' 
		WHEN 2 THEN 'Freight' 
		ELSE 'Misc' END AS [Trans Type]
	, CASE t.TransType 
		WHEN 0 THEN 'NA' --Labor
		WHEN 1 THEN ISNULL(t.ResourceID, '') --Part
		WHEN 2 THEN 'NA' --Freight
		ELSE 'NA' --Misc
		END AS [Resource ID]
	, t.QtyUsed AS [Qty Used]
	, t.UnitPrice AS [Unit Price]
	, t.UnitCost AS [Unit Cost]
	, t.PriceExt AS [Ext Price]
	, t.CostExt AS [Ext Cost] 
FROM dbo.tblSvHistoryWorkOrder o 
	INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON o.ID = d.WorkOrderID 
	INNER JOIN dbo.tblSvHistoryWorkOrderTrans t ON d.WorkOrderID = t.WorkOrderID AND d.ID = t.DispatchID 
	INNER JOIN dbo.tblArCust c ON o.CustID = c.CustID
	LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
WHERE d.EquipmentID IS NOT NULL AND d.CancelledYN = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvEquipmentHistory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvEquipmentHistory';


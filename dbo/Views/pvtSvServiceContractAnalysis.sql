
CREATE VIEW dbo.pvtSvServiceContractAnalysis
AS

SELECT ch.ContractNo AS [Contract No], cd.ContractAmount AS [Contract Amount]
	, CASE cd.CoverageType 
		WHEN 0 THEN 'None' 
		WHEN 1 THEN 'Labor/Parts' 
		WHEN 2 THEN 'Labor' 
		WHEN 3 THEN 'Parts' END AS [Coverage Type]
	, ch.StartDate AS [Start Date], ch.EndDate AS [End Date]
	, o.CustID AS [Customer ID]
	, c.CustName AS [Customer Name]
	, o.WorkOrderNo AS [Order No], o.OrderDate AS [Order Date]
	, e.EquipmentNo AS [Equipment ID], d.EquipmentDescription AS [Equipment Desc]
	, CASE t.TransType 
		WHEN 0 THEN 'Labor' 
		WHEN 1 THEN 'Part' 
		WHEN 2 THEN 'Freight' 
		ELSE 'Misc' END AS [Trans Type]
	, t.ResourceID AS [Resource ID], t.QtyUsed AS [Qty Used]
	, t.UnitPrice AS [Unit Price], t.UnitCost AS [Unit Cost], t.PriceExt AS [Ext Price], t.CostExt AS [Ext Cost] 
FROM dbo.tblSvHistoryWorkOrder o 
	INNER JOIN dbo.tblSvHistoryWorkOrderDispatch d ON o.ID = d.WorkOrderID 
	INNER JOIN dbo.tblSvHistoryWorkOrderTrans t ON d.WorkOrderID = t.WorkOrderID AND d.ID = t.DispatchID 
	INNER JOIN dbo.tblSvServiceContractDetail cd ON d.EquipmentID = cd.EquipmentID 
	INNER JOIN dbo.tblSvServiceContractHeader ch ON cd.ContractID = ch.ID 
	LEFT JOIN dbo.tblSvEquipment e ON d.EquipmentID = e.ID 
	INNER JOIN dbo.tblArCust c ON o.CustID = c.CustID 
WHERE d.CancelledYN = 0
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvServiceContractAnalysis';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtSvServiceContractAnalysis';


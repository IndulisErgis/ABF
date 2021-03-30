
CREATE VIEW dbo.pvtBmMatTran
AS

SELECT h.ItemID AS 'Assembly ID', h.LocID AS 'Assembly Loc ID', h.TransID AS 'Trans ID', h.WorkType AS 'Work Type',
	h.TransDate AS 'Trans Date', d.ItemID AS 'Item ID', d.LocID AS 'Loc ID', d.Uom AS 'UOM', 
	d.UnitCost AS 'Unit Cost', d.ActQty AS 'Actual Qty', d.UnitCost * D.ActQty AS 'Ext Cost',
	d.OriCompQty, h.LaborCost AS 'Labor Cost', l.QtyBkord AS 'Qty Backordered'
FROM dbo.tblBmWorkOrder h INNER JOIN dbo.tblBmWorkOrderDetail d ON h.TransID = d.TransID
	LEFT JOIN dbo.tblBmWorkOrderLot l ON d.TransID = l.TransID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMatTran';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmMatTran';


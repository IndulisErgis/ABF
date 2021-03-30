
CREATE VIEW dbo.pvtBmJrnl
AS

SELECT ActualQty AS 'Actual Qty', UnitCost AS 'Unit Cost', GLAcctCode AS 'GL Acct Code', 
	ItemID AS 'Item ID', LocID AS 'Location ID', ItemType AS 'Item Type', GlYear AS 'Year', 
	GlPeriod AS 'Period', TransID AS 'Trans ID', TransDate AS 'Trans Date',  
	CASE WorkType WHEN 1 THEN 'Build' WHEN 2 THEN 'Unbuild' ELSE 'NA' END AS 'Work Type',
	(ActualQty * UnitCost) AS 'Entry Amount'
FROM dbo.tblBmWorkOrderHist
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmJrnl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'pvtBmJrnl';


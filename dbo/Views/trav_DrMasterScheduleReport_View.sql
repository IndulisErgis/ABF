
Create View [dbo].[trav_DrMasterScheduleReport_View]
As

SELECT i.itemID,i.ProductLine, m.LocId
	FROM dbo.tblDrMstrSched m
	INNER JOIN dbo.tblInItem i ON m.AssemblyId = i.ItemId	 
	INNER JOIN 	(SELECT  BmItemId AssemblyID FROM dbo.tblBmBom GROUP BY BmItemId 
				 UNION
				 SELECT AssemblyId FROM dbo.tblMbAssemblyHeader GROUP BY AssemblyId
				) t ON i.ItemId=t.AssemblyID
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrMasterScheduleReport_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrMasterScheduleReport_View';


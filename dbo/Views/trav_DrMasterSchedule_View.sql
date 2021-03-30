
Create View [dbo].[trav_DrMasterSchedule_View]
As
Select  H.id,D.ProdDate,H.AssemblyId,H.LocId  from dbo.tblDrMstrSched H inner join dbo.tblDrMstrSchedDTl D on H.Id= D.MstrSchedId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrMasterSchedule_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrMasterSchedule_View';



CREATE VIEW dbo.trav_DrAssemblyInformation_View
AS
Select 0 AS [Type], a.[Id], a.[AssemblyId], a.[RevisionNo], a.[Description]
	, a.[MrpCode], a.[Engineer], a.[DfltRevYn]
	From [dbo].[tblMbAssemblyHeader] a
Union All
Select 1 AS [Type], b.[BmBomId] AS [Id], b.[BmItemId] AS [AssemblyId], NULL AS [RevisionNo], b.[Descr] AS [Description]
	, NULL AS [MrpCode], NULL AS [Engineer], 1 AS [DfltRevYn]
	From [dbo].[tblBmBom] b
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrAssemblyInformation_View';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_DrAssemblyInformation_View';


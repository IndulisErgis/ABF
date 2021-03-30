CREATE VIEW [dbo].[ALP_lkpArAlpRegion]
AS
SELECT
	[r].[Region],
	[r].[Name]
FROM [dbo].[ALP_tblArAlpRegion] AS [r]
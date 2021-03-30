
CREATE VIEW [dbo].[trav_WmHistDetail_view] AS

SELECT [hist].*,
       CASE WHEN [hist].[Source] IN (10,11,12,13,14) THEN 1
            WHEN [hist].[Source] IN (70,71,72,88)    THEN 2 
            WHEN [hist].[Source] IN (80,81,82,83,84) THEN 3
            WHEN [hist].[Source] IN (30,31,32)       THEN 4
            WHEN [hist].[Source] IN (75,87)          THEN 5
            WHEN [hist].[Source] IN (16,21)          THEN 6
            WHEN [hist].[Source] IN (74,79)          THEN 7
            WHEN [hist].[Source] IN (18,33,34)       THEN 8
            WHEN [hist].[Source] IN (15,20)          THEN 9
            WHEN [hist].[Source] IN (73,78)          THEN 10
            WHEN [hist].[Source] IN (17,22)          THEN 15
            WHEN [hist].[Source] IN (76,85,86)       THEN 16
            WHEN [hist].[Source] IN (19)             THEN 17
            WHEN [hist].[Source] IN (77)             THEN 18 END AS [TransType]
  FROM [dbo].[tblWmHistDetail] [hist]
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmHistDetail_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_WmHistDetail_view';


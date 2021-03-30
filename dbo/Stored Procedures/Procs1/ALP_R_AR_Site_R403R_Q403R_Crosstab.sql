

CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R403R_Q403R_Crosstab] 
(@StartDate datetime, 
 @EndDate datetime
 )	
AS

SET NOCOUNT ON

SELECT 
Reason, 
[1],
[2],
[3],
[4],
[5],
[6],
[7],
[8],
[9],
[10],
[11],
[12]

FROM 
(
SELECT Reason,CanMonth,Price
FROM ufxALP_R_AR_Site_Q403R(@StartDate,@EndDate)
)
AS Source
PIVOT
(
SUM(Price)
FOR CanMonth
IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12] ) 
)
AS PivotThis
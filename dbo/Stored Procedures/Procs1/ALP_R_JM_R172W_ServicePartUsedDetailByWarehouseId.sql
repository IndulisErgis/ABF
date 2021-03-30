


/****** Object:  StoredProcedure [dbo].[ALP_R_JM_R172W_ServicePartUsedDetailByWarehouseId]    Script Date: 01/08/2013 19:08:59 ******/
CREATE PROCEDURE [dbo].[ALP_R_JM_R172W_ServicePartUsedDetailByWarehouseId] 
(
@StartDate datetime ,
@EndDate datetime,
@WhseId varchar(10)
) 
--created as an offshoot of R172 to account for Van stocks being used through TOA - 10/17/18 - ER

AS
BEGIN
SET NOCOUNT ON;
SELECT 
STI.WhseID,
ST.TicketId, 
ASite.SiteName, 
STI.ItemId, 
STI.[Desc], 
STI.QtyAdded, 
STI.QtyRemoved

FROM 
((ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblJmSvcTktItem AS STI
ON ST.TicketId = STI.TicketId) 
INNER JOIN ALP_tblArAlpSite AS ASite
ON ST.SiteId = ASite.SiteId) 

WHERE	
(STI.PartPulledDate Between @StartDate And @EndDate)
AND (@WhseId = STI.WhseID)
		
GROUP BY 
STI.WhseID,
STI.ItemId,
ST.TicketId,   
ASite.SiteName, 
STI.[Desc], 
STI.QtyAdded, 
STI.QtyRemoved

HAVING
(STI.QtyAdded>0) 
OR (STI.QtyRemoved>0)

END
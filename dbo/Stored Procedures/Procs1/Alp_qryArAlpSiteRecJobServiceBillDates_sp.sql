

CREATE Procedure [dbo].[Alp_qryArAlpSiteRecJobServiceBillDates_sp]      
/* 20qryServiceSelectBillDates */      
 (      
  @RecSvcId int = null      
 )      
As      
declare @FirstRecBillServPriceId as int,      
 @LastRecBillServPriceId as int      
set nocount on      
SET @FirstRecBillServPriceId = (SELECT MIN(RecBillServPriceId)       
    FROM Alp_tblArAlpSiteRecBillServPrice SP2      
    WHERE SP2.RecBillServId =  @RecSvcId)      
SET @LastRecBillServPriceId = (SELECT MAX(RecBillServPriceId)       
    FROM Alp_tblArAlpSiteRecBillServPrice SP2      
    WHERE SP2.RecBillServId =  @RecSvcId)      
SELECT SP.RecBillServId,      
 StartBillDateMin = Min(SP.StartBillDate),       
 EndBillDateMax = Max(SP.EndBillDate),      
 StartBillDateFirst = (SELECT StartBillDate       
    FROM Alp_tblArAlpSiteRecBillServPrice SP2      
    WHERE SP2.RecBillServPriceId =  @FirstRecBillServPriceId),       
 EndBillDateLast = (SELECT EndBillDate       
    FROM Alp_tblArAlpSiteRecBillServPrice SP2      
    WHERE SP2.RecBillServPriceId =  @LastRecBillServPriceId)    
    ,S.Status,CanServEndDate --Added by NSK on 25 Jan 2016  
FROM Alp_tblArAlpSiteRecBillServPrice SP  
INNER JOIN ALP_tblArAlpSiteRecBillServ S   on SP.RecBillServId=S.RecBillServId  --Added by NSK on 25 Jan 2016         
WHERE SP.RecBillServId =  @RecSvcId      
GROUP BY SP.RecBillServId,Status,CanServEndDate;      
return
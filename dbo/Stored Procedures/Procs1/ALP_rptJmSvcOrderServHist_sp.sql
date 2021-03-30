
CREATE PROCEDURE [dbo].[ALP_rptJmSvcOrderServHist_sp]    
--EFI# 1479 MAH 07/12/04 - change joins to allow jobs     
--   with no lead techs to be selected.  
--Added by NSK on 06/11/2014 @NewLineChar declared for new line and 
--Case added for ResDesc to concatenate with the comments.
(    
@ID INT,    
@SysID INT    
)    
AS    
SET NOCOUNT ON 
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)   
SELECT     
ALP_tblJmSvcTkt.SiteId,     
ALP_tblJmSvcTkt.TicketId,     
ALP_tblJmSvcTkt.Status,     
ALP_tblJmWorkCode.NewWorkYN,     
ALP_tblJmSvcTkt.SysId,    
--EFI# 1083 mah 11/22/03: changed TktInfo contents and format    
--TktInfo= '#' + CONVERT(varchar(6), ALP_tblJmSvcTkt.TicketId) + '---'    
-- + CONVERT(varchar(30),ALP_tblJmSvcTkt.CreateDate) + '---'     
-- + CONVERT(varchar(6),Tech)     
-- + '---' + CONVERT(varchar(255),ResDesc)    
ALP_tblJmSvcTktItem.ItemId,    
TktInfo= '#' + CONVERT(varchar(6), ALP_tblJmSvcTkt.TicketId) + '-'    
 + CONVERT(varchar,ALP_tblJmSvcTkt.CreateDate,1) + '-'    
--EFI# 1479 MAH 07/12/04 - handle null Tech as blank    
-- + CONVERT(varchar(6),Tech) + '-'    
 +( CASE WHEN Tech is null OR tech = '' THEN '-'    
 ELSE CONVERT(varchar(6),Tech)    
 END) + '-'    
 + CASE CONVERT(varchar(3),ALP_tblJmResolution.[Action])    
 WHEN 'Ser' THEN 'Svc'    
 WHEN 'Rep' THEN 'Rpl'    
 WHEN 'Rem' THEN 'Rmv'    
 ELSE CONVERT(varchar(3),ALP_tblJmResolution.[Action])    
   END    
 + '-'     
 + COALESCE(('''' + ALP_tblJmSvcTktItem.ItemId + '''-'),'' ) +
 CASE   
	 WHEN Convert(varchar,Comments) is null THEN Convert(varchar,ResDesc)    
	 WHEN Convert(varchar,Comments) = '' THEN Convert(varchar,ResDesc)   
	 Else Convert(varchar,ResDesc)  + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments) 
 End
 -- + CONVERT(varchar(255),ResDesc)     
FROM ALP_tblJmResolution     
INNER JOIN ALP_tblJmWorkCode     
INNER JOIN ALP_tblJmSvcTkt INNER JOIN ALP_tblJmSvcTktItem     
ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId     
ON ALP_tblJmWorkCode.WorkCodeId = ALP_tblJmSvcTkt.WorkCodeId     
--EFI# 1479 MAH 07/12/04 - rearranged joins    
--LEFT JOIN ALP_tblJmTech ON ALP_tblJmSvcTkt.LeadTechId = ALP_tblJmTech.TechID     
ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId    
LEFT JOIN ALP_tblJmTech ON ALP_tblJmSvcTkt.LeadTechId = ALP_tblJmTech.TechID     
WHERE     
ALP_tblJmSvcTkt.TicketId<>@ID    
AND (ALP_tblJmSvcTkt.Status='Closed' or ALP_tblJmSvcTkt.Status='Completed'  )   
AND ALP_tblJmWorkCode.NewWorkYN=0     
AND ALP_tblJmSvcTkt.SysId=@SysId    
ORDER BY ALP_tblJmSvcTkt.TicketId DESC
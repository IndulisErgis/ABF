
  
CREATE PROCEDURE [dbo].[ALP_qryJm130_ChangeTargetDate_sp]  
--EFI# 1638 MAH 11/30/05 - added lead tech  
--For bug id 131. Modified by NSK on 27 Jan 2015 to assign null if there is no LeadTechId
 (   
 @TicketID integer,  
 @TargetDate datetime,  
 @LeadTechID int=null
 )  
AS  
UPDATE    ALP_tblJmSvcTkt  
SET       PrefDate = @TargetDate,  
 Status = CASE   
 WHEN Status = 'New' THEN 'Targeted'   
 ELSE Status  
 END,  
 -- CASE added by NSK on 27 Jan 2015 to assign the null if no LeadTech is passed
 LeadTechId = Case
 When @LeadTechID is null THEN LeadTechID 
 ELSE @LeadTechID 
 END
WHERE     ALP_tblJmSvcTkt.TicketID = @TicketID
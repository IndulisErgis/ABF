create Procedure [dbo].[ALP_qryGetUnPulledTicketItemsForTicket]            
 @TicketID int      
AS   
--Below tblinItem join and  ufn_Alp_GetItemType_PartOnly code added by ravi on 28 oct 2020, to fix the bugid 1219
Select  ALP_tblJmSvcTktItem.ItemId, ALP_tblJmSvcTktItem.PartPulledDate,ALP_tblJmSvcTktItem.TicketId    
,ALP_tblJmSvcTktItem.ResolutionId,ALP_tblJmResolution.Action from ALP_tblJmSvcTktItem      
Inner join ALP_tblJmResolution on ALP_tblJmSvcTktItem.ResolutionId=ALP_tblJmResolution.ResolutionId 
Inner join tblinitem  on   tblinitem .itemid =ALP_tblJmSvcTktItem .ItemId
where ALP_tblJmSvcTktItem.ticketid=@TicketID     
and (ALP_tblJmSvcTktItem.PartPulledDate is Null or ALP_tblJmSvcTktItem.PartPulledDate='')    
and (ALP_tblJmResolution.Action='Add' or ALP_tblJmResolution.Action='Replace')
and [dbo].[ufn_IsItemIsPart](tblinitem.ItemId) = 1
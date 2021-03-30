  
Create Procedure [dbo].[ALP_qryGetUnPulledTicketItemsForProject]          
 @ProjectID varchar(10)    
AS   
Select ALP_tblJmSvcTktItem.PartPulledDate,ALP_tblJmSvcTktItem.TicketId  
,ALP_tblJmSvcTktItem.ResolutionId,ALP_tblJmResolution.Action from ALP_tblJmSvcTktItem    
Inner join ALP_tblJmSvcTkt on ALP_tblJmSvcTktItem.TicketId=ALP_tblJmSvcTkt.TicketId  
Inner join ALP_tblJmResolution on ALP_tblJmSvcTktItem.ResolutionId=ALP_tblJmResolution.ResolutionId  
where ALP_tblJmSvcTkt.ProjectID=@ProjectID  
and (ALP_tblJmSvcTktItem.PartPulledDate is Null or ALP_tblJmSvcTktItem.PartPulledDate='')  
and (ALP_tblJmResolution.Action='Add' or ALP_tblJmResolution.Action='Replace')
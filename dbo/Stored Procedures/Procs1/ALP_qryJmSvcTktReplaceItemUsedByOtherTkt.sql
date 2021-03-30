  
Create PROCEDURE [dbo].[ALP_qryJmSvcTktReplaceItemUsedByOtherTkt]   
@TicketId int  
AS  
Select * from ALP_tblArAlpReplaceCompletedSiteSysItem where TicketId=@TicketId and UsedByOtherTktYN=1
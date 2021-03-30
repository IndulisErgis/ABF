  
Create Procedure [dbo].[ALP_qryUpdUsedByOthrTktYNRepCompSiteSysItem]                
@SysItemId int,    
@TicketId int,  
@UsedByOtherTktYN int  
As                
                
update ALP_tblArAlpReplaceCompletedSiteSysItem  set UsedByOtherTktYN=@UsedByOtherTktYN  
where SysItemId=@SysItemId and TicketId=@TicketId
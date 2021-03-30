CREATE  procedure [dbo].[ALP_qryAlpEI_GetJMSvcTktItems_sp]    
 @TicketID int    
As    
/*Below query where codiontion UnitPrice > 0 commented by ravi on 06.18.2015 , and Added Join with Alp_tblJmResolution table 
the change made as per MAH Email sent on Thu 18-Jun-15 7:40 AM and  in hangout chat on 06.19.2015
*/
/* Created by Ravi for EFI#1962 on 10/03/2013 */    

Begin    
 SELECT     
  ItemId,item.[Desc], Comments,QtyAdded * UnitPrice as Amount,    
  QtyAdded as qty,UOM,UnitPrice    
 FROM  dbo.ALP_tblJmSvcTktItem item     Inner Join dbo.ALP_tblJmResolution resolution on item.ResolutionId= resolution.ResolutionId 
 WHERE  TreatAsPartYN  = 0 and --UnitPrice <> 0 and 
 resolution.Action in('Add','Replace')    
 and TicketID = @TicketID    
End
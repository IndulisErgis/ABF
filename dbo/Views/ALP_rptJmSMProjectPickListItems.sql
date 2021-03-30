CREATE VIEW dbo.ALP_rptJmSMProjectPickListItems 
AS SELECT ItemId, [Desc],                     
SUM(QtyAdded) AS SumOfQtyAdded,                        
 Uom, PartPulledDate,ProjectId,TicketId,DfltBinNum,SysType,ItemType,Phase        
 --added by NSK on 26 May 2015        
 ,KorC         
 --Added by NSK on 31 Aug 2016 for bug id 524.          
 --start          
  ,BinNumber,BODate,StagedDate,Status,OldTicketId         
  --end        
  --Added by NSK on 17 Dec 2018 for bug id 868  
  --start  
  ,HoldInvCommitted
  ,KitNestLevel  
  --end  
 FROM dbo.ALP_lkpJmSvcSMProjectWorkOrderItems GROUP BY ProjectId,                         
  ItemId, [Desc], Uom, PartPulledDate,TicketId,DfltBinNum,SysType,ItemType,Phase,KorC      
  --Added by NSK on 31 Aug 2016 for bug id 524.          
 --start          
  ,BinNumber,BODate,StagedDate,Status ,OldTicketId         
  --end  
   --Added by NSK on 17 Dec 2018 for bug id 868  
  --start  
  ,HoldInvCommitted 
  ,KitNestLevel 
  --end  
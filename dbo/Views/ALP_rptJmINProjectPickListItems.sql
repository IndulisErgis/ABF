CREATE VIEW dbo.ALP_rptJmINProjectPickListItems 
AS SELECT ItemId, [Desc],                       
SUM(QtyAdded) AS SumOfQtyAdded,                          
 Uom, PartPulledDate,ProjectId,TicketId,DfltBinNum,SysType,ItemType,Phase           
 --Below columns added by NSK on 29 Jan 2015 to update the inventory from project pick list          
 ,KorC,Qty,WhseId,AlpVendorKitComponentYn,QtySeqNum_Cmtd,QtySeqNum_InUse,TicketItemId,[Action]        
 --Added by NSK on 31 Aug 2016 for bug id 524.        
 --start        
  ,BinNumber,BODate,StagedDate,Status,OldTicketId       
  --end    
  --Added by NSK on 17 Dec 2018 for bug id 868  
  ,HoldInvCommitted
  ,KitNestLevel             
  --end  
 FROM dbo.ALP_lkpJmSvcINProjectWorkOrderItems GROUP BY ProjectId,                           
  ItemId, [Desc], Uom, PartPulledDate,TicketId,DfltBinNum,SysType,ItemType,Phase          
  --Below columns added by NSK on 29 Jan 2015 to update the inventory from project pick list          
  ,KorC,Qty,WhseId,AlpVendorKitComponentYn,QtySeqNum_Cmtd,QtySeqNum_InUse,TicketItemId,[Action]        
  --Added by NSK on 31 Aug 2016 for bug id 524.        
 --start        
  ,BinNumber,BODate,StagedDate,Status ,OldTicketId       
  --end  
   --Added by NSK on 17 Dec 2018 for bug id 868  
  ,HoldInvCommitted,KitNestLevel                 
  --end
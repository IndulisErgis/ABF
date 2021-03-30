CREATE VIEW dbo.ALP_rptJmSvcPickListItems AS SELECT TicketId, ItemId, [Desc], SUM(QtyAdded) AS SumOfQtyAdded,    
 Uom, PartPulledDate,  
 --added by NSK on 26 May 2015  
 KorC   
 ,BinNumber,StagedDate,BODate --Added by NSK on 25 Aug 2016 for bug id 523           
  FROM dbo.ALP_lkpJmSvcWorkOrderItems GROUP BY TicketId,    
  ItemId, [Desc], Uom, PartPulledDate ,KorC
  ,BinNumber,StagedDate,BODate --Added by NSK on 25 Aug 2016 for bug id 523 
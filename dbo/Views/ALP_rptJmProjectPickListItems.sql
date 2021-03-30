
  CREATE VIEW dbo.ALP_rptJmProjectPickListItems AS SELECT ItemId, [Desc],           
SUM(QtyAdded) AS SumOfQtyAdded,              
 Uom, PartPulledDate,ProjectId,TicketId,DfltBinNum,SysType,ItemType,Phase FROM dbo.ALP_lkpJmSvcProjectWorkOrderItems GROUP BY ProjectId,               
  ItemId, [Desc], Uom, PartPulledDate,TicketId,DfltBinNum,SysType,ItemType,Phase
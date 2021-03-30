CREATE PROCEDURE [dbo].[ALP_qryRptJmINProjectPickListItems]                                        
 @ID varchar(10),                                
 @JmIN int,                                  
 @Tickets varchar(4000)                                        
As                           
-- Modified 11/17/14 by MAH:  Changed to sum the parts qty across all selected jobs.                                     
-- Modified by NSK on 29 Jan 2015 Columns added to update the inventory from project pick list                      
-- Modified by NSK on 18 mar 2015. ProjectId and TicketId assigned directly.Earlier it was NULL AS ProjectId and 0 AS TicketId.                    
-- Modiifed by NSK on 13 Oct 2016. Convert added for TicketId. Order by TicketId added.        
SET NOCOUNT ON                                    
declare @strSql nvarchar(4000)                                 
set @strSql=''                              
 --                            
set @strSql= '                                    
Select ItemId, [Desc], SUM(SumOfQtyAdded) AS SumOfQtyAdded, Uom, PartPulledDate,  DfltBinNum,ProjectId , Convert(varchar(1000),TicketId) as TicketId,  '                        
+ ' SysType, Phase ,KorC,Qty,WhseId,AlpVendorKitComponentYn,QtySeqNum_Cmtd,QtySeqNum_InUse,TicketItemId,[Action] '                
+ ' ,BinNumber,BODate,StagedDate,Status,OldTicketId,HoldInvCommitted,KitNestLevel '                
+ ' from ALP_rptJmINProjectPickListItems '                        
+ ' where ProjectId=''' + @ID + ''' and TicketId in('+@Tickets+') and ItemType=''Part'' GROUP BY '                        
+ ' SysType, DfltBinNum, Phase, ItemId, [Desc], Uom, PartPulledDate ,KorC,Qty,WhseId,AlpVendorKitComponentYn,QtySeqNum_Cmtd,QtySeqNum_InUse,TicketItemId,[Action],ProjectId , TicketId '                           
+ ' ,BinNumber,BODate,StagedDate,Status,OldTicketId,HoldInvCommitted,KitNestLevel '          
+ ' order by SysType,DfltBinNum,Phase, ItemId,TicketId'                                
                              
EXECUTE sp_executesql @strSql
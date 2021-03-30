CREATE PROCEDURE [dbo].[ALP_qryRptJmSMProjectPickListItems]                                    
 @ID varchar(10),                            
 @JmIN int,                              
 @Tickets varchar(4000)                                    
As                      
-- Modified 11/17/14 by MAH:  Changed to sum the parts qty across all selected jobs.                   
-- Modified by NSK on 18 mar 2015. ProjectId and TicketId assigned directly.Earlier it was NULL AS ProjectId and 0 AS TicketId.                                       
-- Modiifed by NSK on 13 Oct 2016. Convert added for TicketId.Added Order by TicketId.     
SET NOCOUNT ON                                
declare @strSql nvarchar(4000)                             
set @strSql=''                          
                           
set @strSql=                                 
' Select ItemId, [Desc], SUM(SumOfQtyAdded) AS SumOfQtyAdded, Uom, PartPulledDate,  DfltBinNum, ProjectId , Convert(varchar(1000),TicketId) as TicketId,  '                    
+ ' SysType, Phase,KorC '            
+ ' ,BinNumber,BODate,StagedDate,Status,OldTicketId,HoldInvCommitted,KitNestLevel '             
+ ' from ALP_rptJmSMProjectPickListItems  '                           
+ ' TicketId in('+@Tickets+') and ItemType=''Part'' GROUP BY '                    
+ ' SysType, DfltBinNum, Phase, ItemId, [Desc], Uom, PartPulledDate , ProjectId , TicketId'            
+ ' ,BinNumber,BODate,StagedDate,Status,OldTicketId,HoldInvCommitted,KitNestLevel '                     
+ ' order by SysType,DfltBinNum,Phase, ItemId,KorC,TicketId'                            
                          
EXECUTE sp_executesql @strSql
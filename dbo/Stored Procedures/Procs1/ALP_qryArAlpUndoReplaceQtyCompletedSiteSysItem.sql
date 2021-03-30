  
Create PROCEDURE [dbo].[ALP_qryArAlpUndoReplaceQtyCompletedSiteSysItem]                
@TicketId int             
As                
SET NOCOUNT ON                
SELECT        RCSS.SysItemId, RCSS.SysId, RCSS.ItemId, RCSS.[Desc], RCSS.LocId, RCSS.PanelYN, RCSS.SerNum, RCSS.EquipLoc, RCSS.Qty, RCSS.UnitCost,   
                         RCSS.WarrPlanId, RCSS.WarrTerm, RCSS.WarrStarts, RCSS.WarrExpires, RCSS.Comments, RCSS.RemoveYN, RCSS.Zone, RCSS.TicketId, RCSS.WorkOrderId,   
                         RCSS.RepPlanId, RCSS.LeaseYN, RCSS.ts, RCSS.ModifiedBy, RCSS.ModifiedDate, RCSS.UsedByOtherTktYN, RCSS.TicketItemId, RI.OriginalSysItemId,   
                         RI.OriginalItemQty  
FROM            ALP_tblArAlpReplaceCompletedSiteSysItem AS RCSS INNER JOIN  
                         ALP_tblJmSvcTktReplaceItem AS RI ON RCSS.TicketItemId = RI.TicketItemId  
                           
where RCSS.TicketId=@TicketId
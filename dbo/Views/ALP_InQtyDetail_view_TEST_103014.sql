CREATE VIEW [dbo].[ALP_InQtyDetail_view_TEST_103014]     
-- 10/30/14:  MAH modified Alp version to call the trav view as is, then add our columns to it.  
AS        
SELECT *,'' as InUse , 0 as QtyInUse, 0 as QtyAvailInWhse, 0 as QtyCommitted , '' as [Status]   FROM trav_InQtyDetail_view  

UNION ALL      
SELECT     'JM' AS Source, tblInQty.Qty,      
   ALP_tblJmSvcTktItem.TicketId AS TransID,       
   ALP_tblJmSvcTktItem.TicketItemId AS EntryNum,       
   ALP_tblArAlpSite.SiteName AS Reference,       
   ALP_tblJmSvcTktItem.PartPulledDate AS ReqShipDate,      
   tblInQty.ItemId, tblInQty.LocId AS LocId,tblInQty.TransType, ALP_tblJmSvcTkt.SiteId as LotNum,      
   InUse=Case When tblInQty.LinkIDSubLine =1 and ALP_tblJmSvcTktItem.PartPulledDate IS Not Null then 'In Use' else '' end      
   ,QtyInUse=Case When tblInQty.LinkIDSubLine =1 and ALP_tblJmSvcTktItem.PartPulledDate IS Not Null   
  then tblInQty.Qty else 0 end    
 ,QtyAvailInWhse=Case When tblInQty.LinkIDSubLine =1 and ALP_tblJmSvcTktItem.PartPulledDate IS Not Null   
  then 0 else tblInQty.Qty end   
 ,QtyCommitted= tblInQty.Qty  , ALP_tblJmSvcTkt.Status      
  
FROM  ALP_tblJmSvcTkt (NOLOCK) INNER JOIN      
   ALP_tblJmSvcTktItem (NOLOCK) ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId LEFT JOIN      
   tblInQty (NOLOCK )ON ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = tblInQty.SeqNum     
   LEFT  JOIN      
   ALP_tblArAlpSite (NOLOCK) ON ALP_tblJmSvcTkt.SiteId = ALP_tblArAlpSite.SiteId 
   --where clause added. mah 08/04/13:     
WHERE  dbo.tblInQty.Qty <> 0 and  ALP_tblJmSvcTkt.Status IN ('New','Scheduled','Completed', 'Closed')
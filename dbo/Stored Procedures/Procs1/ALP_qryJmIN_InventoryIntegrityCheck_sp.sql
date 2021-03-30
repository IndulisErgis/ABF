CREATE Procedure [dbo].[ALP_qryJmIN_InventoryIntegrityCheck_sp]   
AS     
--SET NOCOUNT ON     
    
SET IDENTITY_INSERT tblInQty ON    
--0.  FIND ALL Parts with MULTIPLE InQty records    
select ALP_tblJmSvcTktItem.TicketItemId, Count(tblInQty.LinkIdSub) as RecCount 
INTO #tmpDuplicates_InQty    
FROM         tblInQty right OUTER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 AND (R.Action = 'Add' OR R.Action = 'Replace')    
GROUP BY ALP_tblJmSvcTktItem.TicketItemId  having Count(tblInQty.LinkIdSub) > 1    
  order by Count(tblInQty.LinkIdSub) desc,  ALP_tblJmSvcTktItem.TicketItemId desc  
    
--select 'InQty Duplicates', * from #tmpDuplicates_InQty    
      
--DELETE the Duplicates!    
--0A.  FIND ALL Parts with MULTIPLE InQty records!    
--select ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.PartPulledDate,tblInQty.LinkIdSubLine,     
-- ALP_tblJmSvcTktItem.ItemId,tblInQty.ItemId, ALP_tblJmSvcTktItem.QtyAdded,tblInQty.Qty    
DELETE tblInQty     
FROM       #tmpDuplicates_InQty tmp INNER JOIN tblInQty ON tmp.TicketItemId = tblInQty.LinkIdSub  INNER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 and tblInQty.ItemId = ALP_tblJmSvcTktItem.ItemId    
 and (PartPulledDate is NOT NULL and LinkIdSubLine = 0)    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
--0B.  DELETE MULTIPLE InQty records!    
--select ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.PartPulledDate,tblInQty.LinkIdSubLine,     
-- ALP_tblJmSvcTktItem.ItemId,tblInQty.ItemId, ALP_tblJmSvcTktItem.QtyAdded,tblInQty.Qty    
DELETE tblInQty     
FROM       #tmpDuplicates_InQty tmp INNER JOIN tblInQty ON tmp.TicketItemId = tblInQty.LinkIdSub  INNER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 and tblInQty.ItemId = ALP_tblJmSvcTktItem.ItemId    
 and (PartPulledDate is NULL and LinkIdSubLine = 1)    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
--0C.  FIND ALL Parts with MULTIPLE InQty records!    
--select tblInQty.*, ALP_tblJmSvcTktItem.TicketItemId, ALP_tblJmSvcTktItem.PartPulledDate,tblInQty.LinkIdSubLine,     
-- ALP_tblJmSvcTktItem.ItemId,tblInQty.ItemId, ALP_tblJmSvcTktItem.QtyAdded,tblInQty.Qty, ALP_tblJmSvcTktItem.*    
DELETE tblInQty     
FROM       #tmpDuplicates_InQty tmp INNER JOIN tblInQty ON tmp.TicketItemId = tblInQty.LinkIdSub  INNER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 --and tblInQty.ItemId = ALP_tblJmSvcTktItem.ItemId    
 --and (PartPulledDate is NULL and LinkIdSubLine = 1)    
 and tblInQty.SeqNum <> ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
 --order by  tmp.TicketItemId desc    
    
drop table #tmpDuplicates_InQty    
    
    
----1. PULLED PARTS - SeqNum_Cmtd Discrepancy IT FINDS THE QtySeqNumCmtd value discrepancies , but makes sure Qty and ItemID match! - PULLED PARTS ONLY    
--select 'Broken Link-QtySeqNum_Cmtd-PulledParts', T.Status, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, tblInQty.SeqNum,     
-- ALP_tblJmSvcTktItem.TicketItemId, tblInQty.LinkIdSub, ALP_tblJmSvcTktItem.WhseId, tblInQty.LocID, ALP_tblJmSvcTktItem.QtyAdded, tblInQty.Qty, I.ItemTYpe, *     
--FROM         tblInQty right OUTER JOIN    
--                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
-- and tblInQty.SeqNum <> ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
-- and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
-- and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
-- and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId    
-- and ((LinkIdSubLine = 1 and PartPulledDate is not null)) --this looks only at pulled parts    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by tblInQty.SeqNum desc    
      
--1. FIX the items found above    
--RUN THIS  UPDATE QUERY FIRST.  IT FIXES THE QtySeqNumCmtd value     
UPDATE ALP_tblJmSvcTktItem SET ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = tblInQty.SeqNum    
FROM   tblInQty right OUTER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.SeqNum <> ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
 and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId    
 and ((LinkIdSubLine = 1 and PartPulledDate is not null)) --this looks only at pulled parts    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
----2. NOT PULLED PARTS - SeqNum_Cmtd Discrepancy IT FINDS THE QtySeqNumCmtd value discrepancies , but makes sure Qty and ItemID match!    
--select 'Broken Link-QtySeqNum_Cmtd-Parts NOT pulled',T.Status, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, tblInQty.SeqNum,     
-- ALP_tblJmSvcTktItem.TicketItemId, tblInQty.LinkIdSub, ALP_tblJmSvcTktItem.WhseId, tblInQty.LocID, ALP_tblJmSvcTktItem.QtyAdded, tblInQty.Qty, I.ItemTYpe, *     
--FROM         tblInQty right OUTER JOIN    
--                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
-- and tblInQty.SeqNum <> ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
-- and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
-- and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
-- and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId    
-- and ((LinkIdSubLine = 0 and PartPulledDate is null)) --this looks only at pulled parts    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by tblInQty.SeqNum desc    
    
--2. FIX the items found above    
UPDATE ALP_tblJmSvcTktItem SET ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = tblInQty.SeqNum    
FROM         tblInQty right OUTER JOIN    
                      ALP_tblJmSvcTktItem --ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.SeqNum <> ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
 and tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
 and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
 and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId    
 and ((LinkIdSubLine = 0 and PartPulledDate is null)) --this looks only at pulled parts    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
----3A. Check and fix the  Qty .     
--select 'Qty mismatch', T.Status, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, tblInQty.SeqNum,     
-- ALP_tblJmSvcTktItem.TicketItemId, tblInQty.LinkIdSub, ALP_tblJmSvcTktItem.WhseId, tblInQty.LocID, ALP_tblJmSvcTktItem.QtyAdded, tblInQty.Qty, I.ItemTYpe, *     
--FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
-- and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')      
-- and tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
-- and tblInQty.LinkIdSub =  ALP_tblJmSvcTktItem.TicketItemId    
-- and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
-- and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId     
-- and tblInQty.Qty <> ALP_tblJmSvcTktItem.QtyAdded    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by tblInQty.SeqNum desc    
     
--3B. UPDATE the Qty     
UPDATE tblInQty SET tblInQty.Qty = ALP_tblJmSvcTktItem.QtyAdded    
FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')     
 and tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
 and tblInQty.LinkIdSub =  ALP_tblJmSvcTktItem.TicketItemId    
 and tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
 and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId     
 and tblInQty.Qty <> ALP_tblJmSvcTktItem.QtyAdded    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
    
----4A. Check and fix the Item.     
--select 'Item mismatch', T.Status, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, tblInQty.SeqNum,     
-- ALP_tblJmSvcTktItem.TicketItemId, tblInQty.LinkIdSub, ALP_tblJmSvcTktItem.WhseId, tblInQty.LocID, ALP_tblJmSvcTktItem.QtyAdded, tblInQty.Qty, I.ItemTYpe, *     
--FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')     
-- and tblInQty.ItemID <> ALP_tblJmSvcTktItem.ItemId     
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by tblInQty.SeqNum desc    
    
--4B UPDATE the ItemID    
UPDATE tblInQty SET tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and tblInQty.ItemID <> ALP_tblJmSvcTktItem.ItemId      
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
----4C. Check and fix the InUse Status mismatch.     
--select 'InUse Status mismatch', T.Status, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, ALP_tblJmSvcTktItem.PartPulledDate,tblInQty.LinkIdSubLine,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, tblInQty.SeqNum,     
-- ALP_tblJmSvcTktItem.TicketItemId, tblInQty.LinkIdSub, ALP_tblJmSvcTktItem.WhseId, tblInQty.LocID, ALP_tblJmSvcTktItem.QtyAdded, tblInQty.Qty, I.ItemTYpe, *     
--FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')      
-- and ((tblInQty.LinkIdSubline = 0 AND ALP_tblJmSvcTktItem.PartPulledDate IS NOT NULL)   
-- OR (tblInQty.LinkIdSubline = 1 AND ALP_tblJmSvcTktItem.PartPulledDate IS NULL )  
-- )   
-- --and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)      
-- --and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId     
-- --and tblInQty.Qty <> ALP_tblJmSvcTktItem.QtyAdded    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by tblInQty.SeqNum desc    
    
--4D  Check and fix the InUse Status mismatch.     
UPDATE tblInQty SET tblInQty.LinkIdSubLine = CASE WHEN ALP_tblJmSvcTktItem.PartPulledDate IS NULL THEN 0 ELSE 1 END  --tblInQty.ItemID = ALP_tblJmSvcTktItem.ItemId    
FROM  tblInQty INNER JOIN ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      --ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     tblInQty.LinkId = 'JM'  --(tblInQty.SeqNum is null)  and     
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')     
 and ((tblInQty.LinkIdSubline = 0 AND ALP_tblJmSvcTktItem.PartPulledDate IS NOT NULL)   
 OR (tblInQty.LinkIdSubline = 1 AND ALP_tblJmSvcTktItem.PartPulledDate IS NULL )  
 )    
--and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
 --and tblInQty.LocID = ALP_tblJmSvcTktItem.WhseId     
 --and tblInQty.Qty <> ALP_tblJmSvcTktItem.QtyAdded    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
      
  
----5A. Find any good items with MISSING inQty entries    
--select 'Missing InQty recs', T.Status, T.ProjectID, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId, I.ItemTYpe, *     
--FROM         tblInQty right OUTER JOIN   
--                      ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     (tblInQty.SeqNum is null)      
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
-- and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
-- and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd <> 0    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by T.CreateDate desc, T.TicketID desc     
    
--    
--5B. INSERT missing records - where QtySeqNum_Cmtd <> 0    
--SET IDENTITY_INSERT tblInQty ON    
--GO    
INSERT INTO tblInQty([SeqNum],[ItemId],[LocId],[LotNum],[TransType],[Qty],[LinkID],[LinkIDSub],[LinkIDSubLine])    
select ALP_tblJmSvcTktItem.QtySeqNum_Cmtd, ALP_tblJmSvcTktItem.ItemId, ALP_tblJmSvcTktItem.WhseId, NULL,0,    
  ALP_tblJmSvcTktItem.QtyAdded, 'JM', ALP_tblJmSvcTktItem.TicketItemId, CASE WHEN PartPulledDate is null THEN 0 ELSE 1 END    
FROM         tblInQty right OUTER JOIN    
                      ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     (tblInQty.SeqNum is null)      
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
 and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd <> 0    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
SET IDENTITY_INSERT tblInQty OFF    
    
    
----5C. Find any good items with MISSING inQty entries - where QtySeqNum_Cmtd = 0    
--select 'Missing InQty recs - 0 SeqNum',  T.Status, T.ProjectID, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId, I.ItemTYpe, *     
--FROM         tblInQty right OUTER JOIN    
--                      ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     (tblInQty.SeqNum is null)      
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
-- and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
-- and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = 0    
-- and ALP_tblJmSvcTktItem.WhseId is not null    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by T.CreateDate desc, T.TicketID desc     
    
--5D. INSERT MISSING inQty entries - where QtySeqNum_Cmtd = 0     
INSERT INTO tblInQty([ItemId],[LocId],[LotNum],[TransType],[Qty],[LinkID],[LinkIDSub],[LinkIDSubLine])    
select ALP_tblJmSvcTktItem.ItemId, ALP_tblJmSvcTktItem.WhseId, NULL,0,    
  ALP_tblJmSvcTktItem.QtyAdded, 'JM', ALP_tblJmSvcTktItem.TicketItemId, CASE WHEN PartPulledDate is null THEN 0 ELSE 1 END    
FROM         tblInQty right OUTER JOIN    
                      ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE     (tblInQty.SeqNum is null)      
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
 and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = 0    
 and ALP_tblJmSvcTktItem.WhseId is not null    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
     
UPDATE ALP_tblJmSvcTktItem SET ALP_tblJmSvcTktItem.QtySeqNum_Cmtd  = tblInQty.SeqNum    
FROM         tblInQty INNER JOIN    
                      ALP_tblJmSvcTktItem ON tblInQty.LinkIdSub = ALP_tblJmSvcTktItem.TicketItemId    
                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
WHERE  (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0) 
 --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
 and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = 0    
 and ALP_tblJmSvcTktItem.WhseId is not null    
 and (R.Action = 'Add' OR R.Action = 'Replace')    
    
----6.  Find Ticket Items where LocID is NULL - may have prevented InQty inserts!  HOW TO FIX THIS?       
--select 'Missing WhseID in Ticket Part', T.Status, T.ProjectID, T.CreateDate,ALP_tblJmSvcTktItem.ItemId, tblInQty.ItemId, I.ItemTYpe, *     
--FROM  tblInQty right OUTER JOIN    
--                      ALP_tblJmSvcTktItem ON tblInQty.SeqNum = ALP_tblJmSvcTktItem.QtySeqNum_Cmtd    
--                      inner join ALP_tblJmSvcTkt T on T.TicketID = ALP_tblJmSvcTktItem.TicketId    
--                      inner join ALP_tblJmResolution R ON ALP_tblJmSvcTktItem.ResolutionID = R.REsolutionID    
--                      INNER JOIN tblInItem I ON I.ItemID = ALP_tblJmSvcTktItem.ItemId    
--WHERE     (tblInQty.SeqNum is null)      
-- --and (T.Status = 'New' OR T.Status = 'Targeted' OR T.Status = 'NEW' OR T.Status = 'Scheduled')    
-- and (ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0 and ALP_tblJmSvcTktItem.KittedYn = 0)    
-- --and ALP_tblJmSvcTktItem.QtySeqNum_Cmtd = 0    
-- and ALP_tblJmSvcTktItem.WhseId is null    
-- and (R.Action = 'Add' OR R.Action = 'Replace')    
-- order by T.CreateDate desc, T.TicketID desc     
    
----7A. --FIND  and FIX all parts in CLOSED jobs..verify that the IN records indicate that he part qty is now 0    
--select 'Invalid Qty in Completed/cancelled Jobs', Q.LinkIdSubLine,TI.PartPulledDate, T.Status,  TI.*, Q.SeqNum, TI.QtySeqNum_Cmtd,Q.LinkIDSub,TI.TicketItemId, TI.TicketId,     
--Q.ItemId,TI.KittedYn,  Q.*     
--from tblInQty Q  INNER join ALP_tblJmSvcTktItem TI ON Q.SeqNum = TI.QtySeqNum_Cmtd 
--INNER JOIN ALP_tblJmSvcTkt T ON TI.TicketID = T.TicketId    
--where (LinkID = 'JM' )    
--and Q.Qty <> 0    
--and T.Status IN ('Completed', 'Closed', 'Cancelled')    
--order by Q.LinkIdSubLine,TI.PartPulledDate desc, Q.seqnum desc    
--     
UPDATE tblInQty    
SET Qty = 0    
from tblInQty Q  INNER join ALP_tblJmSvcTktItem TI ON Q.SeqNum = TI.QtySeqNum_Cmtd    
INNER JOIN ALP_tblJmSvcTkt T ON TI.TicketID = T.TicketId    
where (LinkID = 'JM' )    
and Q.Qty <> 0    
and T.Status IN ('Completed', 'Closed', 'Cancelled')    
--
----7B. --FIND  and FIX all parts in CLOSED jobs..verify that the IN records indicate that he part qty is now 0    
--select 'Invalid Qty in Completed/cancelled Jobs',  Q.SeqNum, TI.QtySeqNum_Cmtd,Q.LinkIDSub,TI.TicketItemId,Q.LinkIdSubLine,TI.PartPulledDate, T.Status,  TI.*, TI.TicketId,     
--Q.ItemId,TI.KittedYn,  Q.*     
----from tblInQty Q INNER join ALP_tblJmSvcTktItem TI ON Q.SeqNum = TI.QtySeqNum_Cmtd 
--from tblInQty Q INNER join ALP_tblJmSvcTktItem TI ON Q.LinkIdSub = TI.TicketItemId
--	INNER JOIN ALP_tblJmSvcTkt T ON TI.TicketID = T.TicketId    
--where (LinkID = 'JM' )    
--	and Q.Qty <> 0    
--	and T.Status IN ('Completed', 'Closed', 'Cancelled')    
--order by TI.PartPulledDate desc, Q.LinkIdSubLine desc, Q.seqnum desc 
   
UPDATE tblInQty    
SET Qty = 0 
--from tblInQty Q INNER join ALP_tblJmSvcTktItem TI ON Q.SeqNum = TI.QtySeqNum_Cmtd    
from tblInQty Q INNER join ALP_tblJmSvcTktItem TI ON Q.LinkIdSub = TI.TicketItemId
	INNER JOIN ALP_tblJmSvcTkt T ON TI.TicketID = T.TicketId     
where (LinkID = 'JM' )    
and Q.Qty <> 0    
and T.Status IN ('Completed', 'Closed', 'Cancelled')
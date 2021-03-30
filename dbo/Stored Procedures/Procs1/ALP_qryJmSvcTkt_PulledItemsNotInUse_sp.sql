CREATE PROCEDURE dbo.ALP_qryJmSvcTkt_PulledItemsNotInUse_sp  
 @TicketID int  
-- Created for  EFI# 1529 MAH 12/29/04 - JM-IN Interface  
-- Modified: EFI# 1620 MAH 09/12/05 - do not exclude items already pulled 
--Modified NSK 06/17/16 
As  
SET NOCOUNT ON  
SELECT   
 CASE  
  WHEN KittedYn = 1 THEN 'K'  
  WHEN AlpVendorKitYn <> 0 THEN 'V'  
  WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'  
  ELSE ''  
 END AS KorC,  
 CASE   
  WHEN Uom is null THEN ''  
  ELSE Uom  
 End AS Uom,  
 QtyAdded AS Qty,  
 TicketItemId,  
 ItemId,WhseId,PartPulledDate,AlpVendorKitComponentYn,  
 QtySeqNum_Cmtd,QtySeqNum_InUse,ALP_tblJmResolution.[Action]  
FROM  ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId   
WHERE ALP_tblJmSvcTktItem.TicketId = @TicketID  
 AND (ALP_tblJmResolution.[Action] ='Add' Or ALP_tblJmResolution.[Action] ='Replace') ---- UnCommented by NSK on 17 Jun 2016 to update the replace item inventory list
 --AND (ALP_tblJmResolution.[Action] ='Add' )  -- Commented by NSK on 17 Jun 2016 to update the replace item inventory list
 AND KittedYn = 0 AND AlpVendorKitComponentYn = 0  
-- EFI# 1620 MAH 09/12/05 - commented out:  
-- AND (  
--  (ALP_tblJmSvcTktItem.PartPulledDate Is Null)  
--  OR  
--  (ALP_tblJmSvcTktItem.PartPulledDate Is not Null AND QtySeqNum_InUse = 0)  
-- )  
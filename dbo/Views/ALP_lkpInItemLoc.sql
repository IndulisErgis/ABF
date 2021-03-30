
CREATE VIEW [dbo].[ALP_lkpInItemLoc] AS          
SELECT [ALP_tblInItem_view].[ItemId], [ALP_tblInItem_view].[Descr], [ALP_tblInItemLocation_view].[AlpDfltPts], [ALP_tblInItem_view].[ItemType],          
[ALP_tblInItemLocation_view].[GLAcctCode], [ALP_tblInItemLocation_view].[LocId],[ALP_tblInItem_view].[AlpServiceType],        
-- Case added by NSK on 09 Oct 2014        
--Start        
[ALP_tblInItemLocation_view].ItemLocStatus,      
AlpItemStatus =        
Case         
 WHEN [ALP_tblInItemLocation_view].ItemLocStatus =1 THEN 'Active'        
 WHEN [ALP_tblInItemLocation_view].ItemLocStatus =2 THEN 'Discontinued'        
 WHEN [ALP_tblInItemLocation_view].ItemLocStatus =3 THEN 'Superseded'     
 WHEN [ALP_tblInItemLocation_view].ItemLocStatus =4 THEN 'Obsolete'    
END           
--End        
,          
[ALP_tblInItem_view].SuperId, [ALP_tblInItem_view].[UomDflt],[ALP_tblInItem_view].[AlpPrintOnInvoice] ,           
[ALP_tblInItem_view].[KittedYN],[ALP_tblInItem_view].[AlpVendorKitYn],[ALP_tblInItem_view].[AlpDfltHours]          
,[ALP_tblInItem_view].AlpPhaseCodeID --AlpPhaseCodeID added by NSK on 12 Aug 2016 for bug id 514.
,[ALP_tblInItem_view].AlpCATG
  
FROM ALP_tblInItem_view INNER JOIN ALP_tblInItemLocation_view ON [ALP_tblInItem_view].[ItemId]=[ALP_tblInItemLocation_view].[ItemId]
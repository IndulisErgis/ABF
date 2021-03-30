
        
CREATE VIEW [dbo].[ALP_rptJmSvcWorkOrderItems]       
AS       
SELECT TOP 100 PERCENT dbo.ALP_tblJmSvcTktItem.TicketItemId, dbo.ALP_tblJmSvcTktItem.TicketId,       
dbo.ALP_tblJmResolution.[Action], dbo.ALP_tblJmSvcTktItem.ItemId, dbo.ALP_tblJmSvcTktItem.[Desc],      
 dbo.ALP_tblJmSvcTktItem.QtyAdded, dbo.ALP_tblJmSvcTktItem.KittedYN, dbo.ALP_tblJmSvcTktItem.EquipLoc,      
  dbo.ALP_tblJmSvcTktItem.Uom, dbo.ALP_tblJmSvcTktItem.PartPulledDate, dbo.ALP_tblJmSvcTktItem.[Zone] ,  
  --added by NSK on 26 May 2015  
--start  
 CASE        
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS Null OR KitRef = '') THEN 'K'        
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS not Null OR KitRef <> '') THEN 'CK'        
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS Null OR KitRef = '') THEN 'V'        
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS not Null OR KitRef <> '') THEN 'CV'        
  WHEN KitRef IS Not Null OR KitRef <> '' THEN 'C'        
  ELSE ''        
 END AS KorC     
 --end       
  FROM dbo.ALP_tblJmResolution INNER JOIN dbo.ALP_tblJmSvcTktItem ON dbo.ALP_tblJmResolution.ResolutionId = dbo.ALP_tblJmSvcTktItem.ResolutionId       
WHERE       
--below action condition modified by NSK on 18 May 2015.Replace action records should be displayed.     
--Below KittedYN,AlpVendorKitComponentYn checked is null. Modified by NSK on 19 May 2015        
(dbo.ALP_tblJmResolution.[Action] = 'Add' or dbo.ALP_tblJmResolution.[Action] = 'Replace' )      
 AND (dbo.ALP_tblJmSvcTktItem.KittedYN = 0 or dbo.ALP_tblJmSvcTktItem.KittedYN is null)      
 --below condition commented on 01 June 2015 to display the vendor kit as well as its components.
 --AND (dbo.ALP_tblJmSvcTktItem.AlpVendorKitYn = 0 or dbo.ALP_tblJmSvcTktItem.AlpVendorKitYn is null)     
 ORDER BY dbo.ALP_tblJmSvcTktItem.TicketItemId
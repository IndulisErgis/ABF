CREATE VIEW dbo.ALP_lkpSmItemServiceType AS            
SELECT ItemCode as ItemId, [Desc] as Descr, AlpDfltPts, AlpServiceType, GLAcctInv, NULL AS LocId, NULL AS ItemType,             
AlpItemStatus AS ItemLocStatus, NULL AS SuperId, Units AS UomDflt ,            
AlpKittedYN as KittedYN,AlpVendorKitYn,AlpDfltHours ,          
--AlpItemStatus added by NSK on 24 Sep 2014          
-- Case added by NSK on 09 Oct 2014        
--Start        
AlpItemStatus =         
Case         
 WHEN AlpItemStatus =1 THEN 'Active'        
 WHEN AlpItemStatus =2 THEN 'Discontinued'        
 WHEN AlpItemStatus =3 THEN 'Obsolete'        
END           
--End        
,ALP_tblSmItem_view.AlpPhaseCodeID--AlpPhaseCodeID added by NSK on 12 Aug 2016 for bug id 514.          
FROM ALP_tblSmItem_view WHERE (AlpServiceType = 1) OR (AlpServiceType = 2)
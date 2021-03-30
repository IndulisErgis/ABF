Create    Procedure [dbo].[ALP_qryJmSvcTktGetKitComponents]  
--Created by NSK on 01 Oct 2020 for B1201        
 @CurrentTicketItemId int, @ID int, @LineNumberPrefix varchar(50) = ''          
AS          
SET NOCOUNT OFF          
Select CASE                                  
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS Null OR KitRef = '') THEN 'K'                                  
  WHEN ALP_tblJmSvcTktItem.KittedYn = 1 and (KitRef IS not Null OR KitRef <> '') THEN 'CK'                                  
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS Null OR KitRef = '') THEN 'V'                                  
  WHEN ALP_tblJmSvcTktItem.AlpVendorKitYn <> 0  and (KitRef IS not Null OR KitRef <> '') THEN 'CV'                                  
  WHEN KitRef > 0 THEN 'C' --added by NSK on 08 Sep 2016.                      
  --WHEN KitRef IS Not Null OR KitRef <> ''  THEN 'C' --  commented by NSK on 08 Sep 2016.                               
  ELSE ''                                  
 END AS KorC,ALP_tblJmResolution.[Action],ALP_tblJmSvcTktItem.*         
FROM ALP_tblJmSvcTktItem  Inner Join ALP_tblJmResolution
 ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId         
WHERE ALP_tblJmSvcTktItem.TicketId = @ID           
AND         
(        
 (        
  ALP_tblJmSvcTktItem.KitRef = @CurrentTicketItemId          
    OR          
  ALP_tblJmSvcTktItem.LineNumber LIKE (@LineNumberPrefix + '%')        
 )        
)
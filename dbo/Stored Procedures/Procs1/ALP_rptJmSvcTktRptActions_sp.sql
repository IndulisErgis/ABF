    
    
CREATE PROCEDURE [dbo].[ALP_rptJmSvcTktRptActions_sp]           
--EFI# 1915 MAH 11/29/10 - added Action Comments to the report display          
(          
@TicketID int,          
@IncludeComments bit = 0          
)          
AS          
SET NOCOUNT ON          
DECLARE @NewLineChar AS CHAR(2) = CHAR(13) + CHAR(10)        
SELECT           
TicketId,          
-- Case added for displaying ResDesc with and without comments on 06/11/2014 by NSK        
-- Start        
CASE           
 WHEN @IncludeComments is null THEN ResDesc          
 WHEN @IncludeComments = 0 THEN ResDesc          
 WHEN @IncludeComments <> 0 THEN         
  CASE           
  --VARCHAR(2000) added by NSK on 01 Feb 2018 for bug id 683    
  --start    
   --WHEN Convert(varchar(2000),Comments) is null THEN Convert(varchar,ResDesc)           
   --WHEN Convert(varchar(2000),Comments) = '' THEN Convert(varchar,ResDesc)    
   --Else Convert(varchar(2000),ResDesc)  + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments)         
   --end    
    --Added by NSK on 25 Jul 2018 for bug id 756  
    --start    
    WHEN Convert(varchar(2000),ResDesc) is not null and  Convert(varchar(2000),CauseDesc) is not null and (Convert(varchar(2000),Comments) <>'' ) THEN  
  --Convert(varchar(2000),ResDesc)  + @NewLineChar  +
     'Action: ' + Convert(varchar(2000),ResDesc)    
    + @NewLineChar  + 'Cause: ' + Convert(varchar(2000),CauseDesc)    
   + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments)    
  WHEN Convert(varchar(2000),ResDesc) is null and  Convert(varchar(2000),CauseDesc) is not null and (Convert(varchar(2000),Comments) <>'')THEN  
  Convert(varchar(2000),ResDesc)     
    + @NewLineChar  + 'Cause: ' + Convert(varchar(2000),CauseDesc)    
   + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments)       
  WHEN Convert(varchar(2000),ResDesc) is not null and  Convert(varchar(2000),CauseDesc) is null and (Convert(varchar(2000),Comments)<>'') THEN  
  --Convert(varchar(2000),ResDesc) +   @NewLineChar  + 
    'Action: ' + Convert(varchar(2000),ResDesc)    
   + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments)  
  WHEN Convert(varchar(2000),ResDesc) is null and  Convert(varchar(2000),CauseDesc) is null and (Convert(varchar(2000),Comments) <>'') THEN  
  Convert(varchar(2000),ResDesc)  
   + @NewLineChar  + 'Comment: ' + Convert(varchar(2000),Comments)   
  WHEN Convert(varchar(2000),ResDesc) is not null and  Convert(varchar(2000),CauseDesc) is  null and (Convert(varchar(2000),Comments) ='') THEN  
  --Convert(varchar(2000),ResDesc)  + @NewLineChar  +
    'Action: ' + Convert(varchar(2000),ResDesc)    
  WHEN Convert(varchar(2000),ResDesc) is  null and  Convert(varchar(2000),CauseDesc) is not null and (Convert(varchar(2000),Comments)='') THEN  
  Convert(varchar(2000),ResDesc)  
   + @NewLineChar  + 'Cause: ' + Convert(varchar(2000),CauseDesc)   
  WHEN Convert(varchar(2000),ResDesc) is not null and  Convert(varchar(2000),CauseDesc) is not  null and (Convert(varchar(2000),Comments) ='') THEN  
  --Convert(varchar(2000),ResDesc)  + @NewLineChar  + 
   'Action: ' + Convert(varchar(2000),ResDesc)     
   + @NewLineChar  + 'Cause: ' + Convert(varchar(2000),CauseDesc)    
   WHEN Convert(varchar(2000),ResDesc) is null and  Convert(varchar(2000),CauseDesc) is null and (Convert(varchar(2000),Comments)='') THEN  
  Convert(varchar(2000),ResDesc)  
    --end  
     
  End        
END AS ResDesc,          
-- End        
CASE           
 WHEN @IncludeComments is null THEN ''          
 WHEN @IncludeComments = 0 THEN ''          
 WHEN @IncludeComments <> 0  THEN Comments          
END AS Comments,          
ItemId,           
[Desc],           
QtyAdded,           
EquipLoc,           
KittedYN,      
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
FROM ALP_tblJmSvcTktItem           
WHERE KittedYN =0 and TicketID=@TicketID
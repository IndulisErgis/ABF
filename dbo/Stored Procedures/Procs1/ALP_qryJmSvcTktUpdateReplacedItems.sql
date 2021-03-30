CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateReplacedItems]  
@ID int,@ModifiedBy varchar(50)  
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50   
As  
SET NOCOUNT ON  
UPDATE ALP_tblArAlpSiteSysItem  
SET ALP_tblArAlpSiteSysItem.UnitCost = [ALP_tblJmSvcTktItem].[UnitCost], ALP_tblArAlpSiteSysItem.LocId = [ALP_tblJmSvcTktItem].[WhseId],   
 ALP_tblArAlpSiteSysItem.[Desc] = [ALP_tblJmSvcTktItem].[Desc], ALP_tblArAlpSiteSysItem.SerNum = [ALP_tblJmSvcTktItem].[SerNum],   
 ALP_tblArAlpSiteSysItem.[Zone] =   
  CASE WHEN ALP_tblJmSvcTktItem.Zone = '' THEN Null  
  ELSE ALP_tblJmSvcTktItem.Zone  
  END,   
 ALP_tblArAlpSiteSysItem.Comments = [ALP_tblJmSvcTktItem].[Comments], ALP_tblArAlpSiteSysItem.EquipLoc = [ALP_tblJmSvcTktItem].[EquipLoc],   
 -- Ravi - 06 Oct 2017- PanelYN case statement added
 ALP_tblArAlpSiteSysItem.PanelYN = case when [ALP_tblJmSvcTktItem].[PanelYn] is null then '' else [ALP_tblJmSvcTktItem].[PanelYn] end
 , ALP_tblArAlpSiteSysItem.TicketId = @ID,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE() 
 -- Ravi - 06 Oct 2017- WarrExpires column added in update statement
  , ALP_tblArAlpSiteSysItem.WarrExpires =    CASE WHEN WarrTerm = 0 THEN WarrStarts    ELSE DateAdd(month,[WarrTerm],WarrStarts)  END
FROM ALP_tblJmResolution INNER JOIN (ALP_tblArAlpSiteSysItem INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblArAlpSiteSysItem.SysItemId = ALP_tblJmSvcTktItem.SysItemId)   
 ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId   
WHERE ALP_tblJmResolution.[Action] ='Replace' AND ALP_tblJmSvcTktItem.TicketId = @ID
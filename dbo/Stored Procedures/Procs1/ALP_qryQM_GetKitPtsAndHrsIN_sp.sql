CREATE PROCEDURE [dbo].[ALP_qryQM_GetKitPtsAndHrsIN_sp]  
 (  
 @KitRef int = 355519,  
 @LocId varchar(10) = '',  
 @CommercialYn bit = 0,  
 @ItemId pItemId = ''  OUTPUT,  
 @Points decimal(10,2) = 0  OUTPUT,  
 @Hours decimal(10,2) = 0  OUTPUT  
 )  
AS  
set nocount on  
--Ravi5/9/2019 -alter the query for quote and directly used the itemid  in loaction table instead of put the join with 
--alp_tbljmsvctktitem table, because the quote item table available in different database
--MAH 07/27/11 - changed hours and points output from int to decimal  
--MAH 01/22/13 - added commercialYN parameter  
--MAH 03/02/14 - corrected Hours assignment  
SELECT     @ItemId = IL.ItemId,   
 --@Points = isnull(IL.AlpDfltPts,0),   
 @Points = Case when @CommercialYn <> 0   
   THEN isnull(IL.AlpDfltCommercialPts,0)   
   ELSE isnull(IL.AlpDfltPts,0)  
   End ,   
 --@Hours = isnull(IL.AlpDfltHours,0)  
 @Hours = Case when @CommercialYn <> 0   
   THEN isnull(IL.AlpDfltCommercialHours,0)   
   --ELSE isnull(IL.AlpDfltPts,0)  
   ELSE isnull(IL.AlpDfltHours,0)  
   End    
FROM      ALP_tblInItemLocation_view IL  
WHERE IL.LocId = @LocId and IL.ItemId =@ItemId
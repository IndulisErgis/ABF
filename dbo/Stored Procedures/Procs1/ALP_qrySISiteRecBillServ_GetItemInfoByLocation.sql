
CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBillServ_GetItemInfoByLocation]  
(  
 @ItemId pItemID,  
 @LocId pLocID  
)  
AS  
BEGIN 
 --Ravi M Date: 27 Oct 2016: Query changed for Unit price and Location
 --Ravi M Date: 28 Oct 2016: Get price records for Default UOM
 SELECT   
  [i].[Descr] AS [Desc],  
 CASE WHEN  [il].[CostBase] IS NULL THEN 0 ELSE [il].[CostBase]END AS [UnitCost],  
 CASE WHEN [ilup].[PriceBase] IS NULL THEN 0 ELSE [ilup].[PriceBase] END AS [UnitPrice],  
 -- [s].[ServiceTypeId],  
  [i].[AlpServiceType] AS ServiceTypeId ,
  [i].[AlpAcctCode]  ,
 CASE WHEN [il].LocId IS NULL THEN  1 ELSE 0 END AS MissingLocRecord, 
 CASE WHEN [ilup].[PriceBase] IS NULL THEN 1 ELSE  0 END  as MissingPriceRecord
 FROM [dbo].[ALP_tblInItem_view] AS [i]  
 LEFT OUTER JOIN [dbo].[tblInItemLoc] AS [il]  
  ON [i].[ItemId] = [il].[ItemId]  
 LEFT OUTER JOIN [dbo].[tblInItemLocUomPrice] AS [ilup]  
  ON [il].[ItemId] = [ilup].[ItemId]  
  AND [il].[LocId] = [ilup].[LocId] 
   AND [i].UomDflt =[ilup] .Uom
 --INNER JOIN [dbo].[ALP_tblArAlpServiceType] AS [s]  
 -- ON [s].[ServiceTypeId] = [i].[AlpServiceType]  
 WHERE [i].[ItemId] =@ItemId  
 AND( [il].[LocId] =  @LocId  or [il].LocId IS NULL)
END
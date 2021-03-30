

CREATE PROCEDURE [dbo].[ALP_R_AR_R725_InventoryMarginAnalysis]
(
@WhseID varchar(10),
@Margin int,
@Compare varchar (20)
)
AS
BEGIN
SET NOCOUNT ON

SELECT
ItemPrice.ItemId, 
ItemPrice.LocId, 
CostBase, 
CostAvg, 
CostLast, 
Uom, 
PriceBase,
CostAvg/CostBase AS AvgCompare,
CostLast/CostBase AS LastCompare,
CASE WHEN @Compare = 'Average' THEN CostAvg/CostBase
ELSE CostLast/CostBase END AS MarginCompare
 
FROM [dbo].[tblInItemLoc] AS ItemLoc
  INNER JOIN [dbo].[tblInItemLocUomPrice] AS ItemPrice
  ON ItemLoc.ItemId = ItemPrice.ItemId AND ItemLoc.LocId = ItemPrice.LocId
  
WHERE
	CostBase != 0 AND
	(ItemPrice.LocId=@WhseID OR @WhseID='<ALL>') AND
	((CASE WHEN @Compare = 'Average' THEN CostAvg/CostBase
ELSE CostLast/CostBase END>(1+@Margin*.01)) 
OR (CASE WHEN @Compare = 'Average' THEN CostAvg/CostBase
ELSE CostLast/CostBase END<(1-@Margin*.01)))
 

END
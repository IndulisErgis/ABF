



CREATE PROCEDURE [dbo].[ALP_R_AR_R724_InvVal_LastCost_CurrDate]
(
@WhseID varchar(10)
)
AS
BEGIN
SET NOCOUNT ON
/* from qryIn-R724-PartsOnly */

SELECT 
QtyALL.ItemId, 
QtyALL.LocId, 
II.Descr, 
QtyALL.CostLast, 
QtyALL.CostAvg, 
QtyALL.OnHand, 
QtyALL.InUse, 
QtyALL.Committed, 
QtyALL.InStock, 
--mah 02/09/15
----IsNull(OnHand,0)* IsNull(CostLast,0) AS valuelast, 
----IsNull(OnHand,0)* IsNull(CostAvg,0) AS valueavg, 
--err 08/06/15 - modified Case statements and vaulelast/valueavg calculations to use InStock+InUse 
---------------- instead of only InStock
--err 12/2/15 - removed less than zero check added on 2/9/15, while keeping instock+InUse change
--CASE WHEN IsNull((InStock+InUse),0) <= 0 THEN 0
--ELSE IsNull((InStock+InUse),0)* IsNull(CostLast,0) END AS valuelast,
IsNull((InStock+InUse),0)* IsNull(CostLast,0) AS valuelast,  
--CASE WHEN IsNull((InStock+InUse),0) <= 0 THEN 0
--ELSE IsNull((InStock+InUse),0)* IsNull(CostAvg,0) END AS valueavg, 
IsNull((InStock+InUse),0)* IsNull(CostAvg,0) AS valueavg, 
--mah added On Hand valuation, for future validation use when JM is used to provide JM valuation
CASE WHEN IsNull(OnHand,0) <= 0 THEN 0
ELSE IsNull(OnHand,0)* IsNull(CostLast,0) END AS OnHandvaluelast, 
CASE WHEN IsNull(OnHand,0) <= 0 THEN 0
ELSE IsNull(OnHand,0)* IsNull(CostAvg,0) END AS OnHandvalueavg, 
II.UomDflt, 
II.ItemType



FROM 
	ufxALP_R_AR_In_Q708_QtyAll() AS QtyALL
	INNER JOIN ALP_tblInItem_view AS II 
	ON QtyALL.ItemId = II.ItemId
	
WHERE II.ItemType<>3 and (QtyALL.LocId=@WhseID OR @WhseID='<ALL>')

SELECT @@ROWCOUNT as 'Rowcount'
END
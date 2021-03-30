







CREATE PROCEDURE [dbo].[ALP_R_AR_R724E_InvVal_LastCost_CurrDate]
(
@WhseID varchar(10),
@MFG varchar (50),
@ProductLine varchar (30),
@MaxDollar int,
@MinDollar int,
@Active varchar(10),
@ItemIDHigh varchar(50),
@ItemIDLow varchar(50),
@Category varchar (MAX),
@IDBeginsWith varchar (20)
)
AS
BEGIN
SET NOCOUNT ON

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
--err 11/27/15 - removed less than zero check used in base R724 report
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
II.ItemType,
IsNull(II.ALPCATG,'NO CATEGORY')AS Category,
II.ItemStatus

FROM 
	ufxALP_R_AR_In_Q708_QtyAll() AS QtyALL
	INNER JOIN ALP_tblInItem_view AS II 
	ON QtyALL.ItemId = II.ItemId
		
WHERE II.ItemType<>3 and (QtyALL.LocId=@WhseID OR @WhseID='<ALL>') 
	AND (II.AlpMFG=@MFG OR @MFG='<ALL>') AND (II.ProductLine=@ProductLine OR @ProductLine='<ALL>')
	AND (IsNull((InStock+InUse),0)* IsNull(CostAvg,0) BETWEEN @MinDollar and @MaxDollar)
	--AND (II.ItemStatus=@Active OR @Active=5) 
	AND (II.ItemId BETWEEN @ItemIDLow and @ItemIDHigh) 
	AND (II.ItemId LIKE @IDBeginsWith + '%' OR @IDBeginsWith ='')
SELECT @@ROWCOUNT as 'Rowcount'
END
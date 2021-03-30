

CREATE PROCEDURE [dbo].[ALP_R_IN_R723_InvVal_BaseCost_CurrDate]
(
@WhseID varchar(10)
)
AS
BEGIN
SET NOCOUNT ON
-- Converted from Access qryIn-R723 12/12/14 - ER

SELECT 
QtyALL.ItemId, 
QtyALL.LocId, 
II.Descr, 
QtyAll.CostBase,
QtyAll.CostStd,
QtyALL.OnHand, 
QtyALL.InUse, 
QtyALL.Committed, 
QtyALL.InStock, 
IsNull(OnHand,0)* IsNull(CostBase,0) AS valuebase, 
IsNull(OnHand,0)* IsNull(CostStd,0) AS valuestd, 
II.UomDflt, 
II.ItemType


FROM 
	ufxALP_R_AR_In_Q708_QtyAll() AS QtyALL
	INNER JOIN ALP_tblInItem_view AS II 
	ON QtyALL.ItemId = II.ItemId
	
WHERE II.ItemType<>3 and (QtyALL.LocId=@WhseID OR @WhseID='<ALL>')

SELECT @@ROWCOUNT as 'Rowcount'
END
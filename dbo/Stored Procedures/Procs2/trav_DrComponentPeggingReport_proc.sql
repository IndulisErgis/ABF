
CREATE PROCEDURE [dbo].[trav_DrComponentPeggingReport_proc]

@PrecQty tinyint = 4
AS

BEGIN TRY
SET NOCOUNT ON
--1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256=WorkOrds / 512=WorkOrdComp / 1024=WM Transfer / 2048=JC Estimates  
--Component pegging Report  
  
	SELECT r.RunId,r.SeqNum,r.ItemId, r.LocId, t.Descr, t.UOMDflt
	, Case r.Source 
		When 16 Then 10
		When 32 Then 20
		When 1 Then 30
		When 2 Then 40
		When 8 Then 50
		When 512 Then 50
		When 64 Then 50 --include MS comp demand as components
		When 4 Then 60
		When 256 Then 65
		When 1024 Then 70
		When 2048 Then 80
	End SourceSort
	, r.TransDate, r.TransType, r.Source
	, Cast(Round(r.Qty / t.ConvFactor, @PrecQty) as float) AS Quantity
	, r.LinkIDSub OrderNo
	, Case When r.Source = 4 or r.Source = 8 Then left(isnull(r.LinkIDSubLine, ''), 3) Else rtrim(r.LinkIdSubLine) End LineNum
	, r.CustId, r.VendorId, r.AssemblyId
 	FROM dbo.tblDRRunData r
 	INNER JOIN dbo.tblInItemLoc l on r.ItemId = l.ItemId and r.LocID = l.LocId
	LEFT JOIN (Select i.ItemId, i.Descr, i.UOMDflt
		, Case when isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End ConvFactor 
		From dbo.tblInItem i left join dbo.tblInItemUOM u
		on i.ItemId = u.ItemId and i.UOMDflt = u.UOM) t	on r.ItemId = t.ItemId
	INNER JOIN #tmpDrComponentPeggingReport f on  f.RunId=r.RunId and f.SeqNum=r.SeqNum      

      
END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrComponentPeggingReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrComponentPeggingReport_proc';


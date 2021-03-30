
Create procedure [dbo].[trav_DrDailyDetailMRPReport_proc]
@SalesTimeFencePds smallint =Null,  
@ProdTimeFencePds smallint=Null, 
@PrecQty tinyint = 4,
@PrecUCost tinyint = 4,
@WksDate Datetime= Null
As

BEGIN TRY
SET NOCOUNT ON


--1=PurchOrds / 2=PurchReqs / 4=ProdOrds / 8=ProdOrdComp / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 1024=WM Transfer / 2048=JC Estimates
--Detail MRP Report

Declare @LateDate datetime
Declare @SalesTimeFenceDate datetime
Declare @ProdTimeFenceDate datetime
Declare @MaxCtrLen smallint --PTS 44380
declare @convdate nvarchar(10)
--Declare @Done bit

If isnull(@WksDate,'')='' 
Begin
 Set @convdate=convert(nvarchar(10),GETDATE(),101)
 Set @WksDate =CONVERT(smalldatetime,@convdate,101)
 
End
 
 --build temp table to hold base item info for items within selected range
Create table #Items
(
RunId pPostRun NOT NULL ,
ItemId pItemId NOT NULL ,
LocId pLocId NOT NULL ,
QtyOnHand pDecimal NOT NULL DEFAULT (0),
UOM pUOM null,
ConvFactor pDecimal default(1)
)

--temp table for net aval per date calc
Create table #Trans
(
TransOrder int identity(1,1),
SeqNum int,
ItemId pItemId,
LocId pLocId,
TransDate datetime,
MRPDate datetime null,
Source smallint,
Qty pDecimal default (0),
QtyAdj pDecimal default(0)
)

--set date for prior/last period
Select @LateDate = dateadd(dd, -1, @WksDate)

--must find the respective date for the given time fence periods 
--	to determine usage of actual vs forecasted quantity values
Select @SalesTimeFenceDate = Case When @SalesTimeFencePds is NULL Then Cast('99991231' as datetime) 
							Else Case When @SalesTimeFencePds < 1 Then @LateDate 
								Else Dateadd(dd, @SalesTimeFencePds, @LateDate) 
							End End
	, @ProdTimeFenceDate = Case When @ProdTimeFencePds is NULL Then Cast('99991231' as datetime) 
							Else Case When @ProdTimeFencePds < 1 Then @LateDate 
								Else Dateadd(dd, @ProdTimeFencePds, @LateDate) 
							End End

--capture list of selected items.. Applies Filter

Insert into #Items (RunId,ItemId, LocId, QtyOnHand, UOM, ConvFactor)
Select r.RunId,r.ItemId, r.LocId, r.QtyOnHand, i.UomDflt
	, Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End
	From dbo.tblDRRunItemLoc r 
	inner join dbo.tblInItem i
	on r.ItemId = i.ItemId
	inner join dbo.tblinitemloc l              
	on r.itemid = l.itemid and r.locid = l.locid 
	Left join dbo.tblInItemUom u 
		on i.ItemId = u.ItemId and i.UomDflt = u.UOM
	inner join #tmpDrDailyDetailMRPReport f
		on f.ItemId = r.ItemId and f.LocId = r.LocId and f.RunId=r.RunId
		

--capture the transactions to process
Insert into #Trans (SeqNum, ItemId, LocId, TransDate, Source, Qty, QtyAdj, MRPDate)
Select r.SeqNum, r.ItemId, r.LocId, r.TransDate, r.Source, r.Qty, 0
	, Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End
	From dbo.tblDRRunData r inner join #Items i
	on r.ItemId = i.ItemId and r.LocId = i.LocId
	
	and Case When Source in (8, 16, 32, 64, 2048, 512) Then
			--split by the sales and/or production time fence
			Case Source 
				When 16 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End <= @SalesTimeFenceDate) Then 1 Else 0 End 
				When 32 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End > @SalesTimeFenceDate) Then 1 Else 0 End
				When 8 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End <= @ProdTimeFenceDate) Then 1 Else 0 End
				When 64 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End > @ProdTimeFenceDate) Then 1 Else 0 End
				When 2048 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End <= @SalesTimeFenceDate) Then 1 Else 0 End 
				When 512 Then Case When (Case When r.TransDate < @WksDate then @LateDate Else r.TransDate End <= @ProdTimeFenceDate) Then 1 Else 0 End

			End
		Else
			1
		End = 1 --only process the applicable quantities
	order by r.ItemId, r.LocId, r.TransDate,r.LinkIDSub





Select @MaxCtrLen = len(cast(Max(TransOrder) as nvarchar)) From #Trans --PTS 44380
Select @MaxCtrLen = Case When isnull(@MaxCtrLen, 0) < 1 Then 1 Else @MaxCtrLen End --PTS 44380
--copy


--Update the QtyAdj based on the given time fences
Update #Trans Set QtyAdj = tmp.QtyAdj
From (Select SeqNum, (Select Sum( 
		Case When sc.Source in (8, 16, 32, 64, 2048, 512) Then
			--reduce qty(8,16,32,64,2048) --split by the sales and/or production time fence
			Case Source 
				When 16 Then Case When MRPDate <= @SalesTimeFenceDate Then -sc.Qty Else 0 End 
				When 32 Then Case When MRPDate > @SalesTimeFenceDate Then -sc.Qty Else 0 End
				When 8 Then Case When MRPDate <= @ProdTimeFenceDate Then -sc.Qty Else 0 End
				When 64 Then Case When MRPDate >  @ProdTimeFenceDate Then -sc.Qty Else 0 End
				When 2048 Then Case When MRPDate <= @SalesTimeFenceDate Then -sc.Qty Else 0 End
				When 512 Then Case When MRPDate <= @ProdTimeFenceDate Then -sc.Qty Else 0 End
				 
			End
		Else	--increase to qty (1,2,4,128,1024)
			sc.Qty
		End
		)
		From #Trans sc 
			Where sc.itemid = #Trans.ItemId and sc.LocId = #Trans.LocId 
			and ((sc.transDate < #Trans.TransDate) --must account for the sort order of the output (i.e. Source) --PTS 44380
			or ((sc.transDate = #Trans.TransDate)
				and ((sc.Source * power(10, @MaxCtrLen)) + sc.TransOrder) <= ((#Trans.Source * power(10, @MaxCtrLen)) + #Trans.TransOrder)))) QtyAdj 
			-- and sc.transDate <= #Trans.TransDate and sc.TransOrder <=#Trans.TransOrder) QtyAdj 

	From #Trans) tmp
Where #Trans.SeqNum = tmp.SeqNum


--return the resultset in the default UOM

	Select q.RunId,q.ItemId, q.LocId, i.Descr, q.Uom UomDflt, i.UsrFld1, i.UsrFld2  
	 , Cast(Round(l.CostStd * q.ConvFactor, @PrecUCost) As Float) AS StandardCost  
	 , Cast(Round(q.QtyOnHand / q.ConvFactor, @PrecQty) As Float) QtyOnHand  
	 , Cast(Round(t.Qty / q.ConvFactor, @PrecQty) As Float)  AS Quantity  
	 , Cast(Round(l.QtySafetyStock * p.ConvFactor / q.ConvFactor, @PrecQty) As Float) QtySafetyStock  
	 , l.DfltVendId, Cast(l.DfltLeadTime As Float) DfltLeadTime, Cast((l.QtyOrderMin*p.ConvFactor) As Float) OrderSize  
	 , CAST(CONVERT(nvarchar(8), t.TransDate, 112) AS nvarchar) AS TransDateSort
	 ,t.TransDate, t.Source, d.LinkIdSub, d.LinkIdSubLine  
	 , Cast(Round((q.QtyOnHand + t.QtyAdj) / q.ConvFactor, @PrecQty) As Float)  AS ProjectedAvailable 
	From #Items q  
	Inner Join dbo.tblInItem i on q.ItemId = i.ItemId  
	Inner Join dbo.tblInItemLoc l on q.ItemId = l.ItemId and q.LocId = l.LocId  
	Inner Join dbo.tblInItemUom p on l.ItemId = p.ItemId and p.Uom = l.OrderQtyUom  
	Inner Join #Trans t on t.ItemId = l.ItemId and t.LocId = l.LocId  
	inner join dbo.tblDRRunData d on t.SeqNum = d.SeqNum  
	order by t.TransOrder

END TRY
BEGIN CATCH
EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrDailyDetailMRPReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrDailyDetailMRPReport_proc';


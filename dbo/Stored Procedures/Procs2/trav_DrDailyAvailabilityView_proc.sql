
Create Procedure dbo.trav_DrDailyAvailabilityView_proc
(
@RunId pPostRun,
@ItemId pItemId,
@LocId pLocId,
@UOM pUOM,
@StartDate Datetime,
@CutOffDate Datetime,
@OptFlags int,
@PrecQty tinyint = 4
)
AS
BEGIN TRY
SET NOCOUNT ON
--1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256=WorkOrds / 512=WorkOrdComp / 1024=WM Transfer / 2048=JC Estimates
Declare @RetVal int
Declare @QtyOnHand pDecimal
Declare @ConvFactor pDecimal
Declare @tmpDate datetime

--date list 
Create table #DateList(PdId int identity(1, 1), IncDate datetime)

--period qty buckets
Create table #PdQtys
(
	PdDate datetime Null, 
	OnHand pDecimal default(0),
	SoCmtd pDecimal default(0), 
	DrCmtd pDecimal default(0), 
	BmCmtd pDecimal default(0),
	MpCmtd pDecimal Default(0),
	BmOnOrder pDecimal default(0), 
	MpOnOrder pDecimal default(0),
	PoPurReq pDecimal default(0),
	PoOnOrder pDecimal default(0),
	WmOnOrder pDecimal default(0),
	JcCmtd pDecimal default(0),
	NetAvail pDecimal default (0)
)
--capture current on hand qty for non-serialized and serialized items
Select @QtyOnHand = QtyOnHand
	From dbo.tblDRRunItemLoc
	Where RunId = @RunId and ItemId = @ItemId and LocId = @LocId

--ensure value isn't null
Select @QtyOnHand = isnull(@QtyOnHand, 0)

--build the date range starting with todays date
Select @tmpDate = @StartDate
While @tmpDate <= @CutoffDate
Begin
	Insert into #DateList(IncDate) Values (@tmpDate)
	Set @tmpDate = dateadd(dd, 1, @tmpDate)
End

--capture bucketed quantities
Insert into #PdQtys(PdDate, SoCmtd, DrCmtd, BmCmtd,MpCmtd, BmOnOrder,MpOnOrder, PoPurReq, PoOnOrder, WmOnOrder, JcCmtd)
Select Case When t.TransDate < @StartDate Then @StartDate Else d.IncDate End
		, Round(Sum(Case When (t.Source & @OptFlags) = 16 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When ((t.Source & @OptFlags) = 32)  or ((t.Source & @OptFlags) = 64) Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 512 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 8 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 256 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 4 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 2 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 1 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 1024 Then t.Qty Else 0 End), @PrecQty)
		, Round(Sum(Case When (t.Source & @OptFlags) = 2048 Then t.Qty Else 0 End), @PrecQty)
	From #DateList d, (Select convert(datetime, convert(varchar(10),  TransDate, 101)) TransDate, Source, Qty 
			From dbo.tblDRRunData
			Where RunId = @RunId and ItemId = @ItemId and LocId = @LocId) t
Where t.TransDate = d.IncDate 
Group By Case When t.TransDate < @StartDate Then @StartDate Else d.IncDate End


--pack table to ensure records exist for each #DateList period
Insert into #PdQtys(PdDate) Select IncDate From #DateList Where IncDate not in (Select PdDate From #PdQtys)

--calcualte the Net Avail per period
Update #PdQtys Set #PdQtys.NetAvail = @QtyOnHand + isnull(tmp.NetAvail, 0)
From (Select d.PdDate
	, (Select Sum(PoOnOrder + (BmOnOrder+MpOnOrder) + PoPurReq - (BmCmtd+MpCmtd) -  DrCmtd - SoCmtd + WmOnOrder - JcCmtd)
		From #PdQtys q
		Where q.PdDate <= d.PdDate) NetAvail 
	From #PdQtys d) tmp
Where #PdQtys.PdDate = tmp.PdDate

--update the On Hand quantity for each Period
--adjust each active period
Update #PdQtys Set #PdQtys.OnHand = isnull(tmp.OnHand, @QtyOnHand)
From (Select d.PdDate
	, (Select Top 1 NetAvail From #PdQtys q
		Where q.PdDate < d.PdDate
		Order by q.PdDate Desc) OnHand
	From #PdQtys d) tmp
Where #PdQtys.PdDate = tmp.PdDate

SELECT @ConvFactor = case when isnull(ConvFactor,0)=0 then 1 else ConvFactor end
FROM dbo.tblInItemUom
WHERE ItemID = @ItemID and Uom = @Uom


Select @ItemId ItemId, @LocId LocId, PdDate as 'Date'
	, Cast(Round(OnHand / @ConvFactor, @PrecQty) as float) OnHand
	, Cast(Round((SoCmtd + DrCmtd + (BmCmtd+MpCmtd) + JcCmtd) / @ConvFactor, @PrecQty) as float) Demand
	, Cast(Round(((BmOnOrder+MpOnOrder) + PoPurReq + PoOnOrder + WmOnOrder) / @ConvFactor, @PrecQty) as float) Supply
	, Cast(Round(NetAvail / @ConvFactor, @PrecQty) as float) NetAvail
from #PdQtys
Where @ItemId <> '' --exclude data when no item id is specified
Order by PdDate


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrDailyAvailabilityView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrDailyAvailabilityView_proc';


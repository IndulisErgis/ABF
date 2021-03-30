
Create Procedure dbo.trav_DrPlannedProduction_proc
(
@WksDate Datetime,
@RunId pPostRun,
@PdDefId nvarchar(10),
@ShowPriorYn bit=0
)
AS
BEGIN TRY
SET NOCOUNT ON
Declare @UserId pUserId
Declare @WrkStnId pWrkStnId
Declare @LateDate datetime
Declare @TimeFencePds smallint
Declare @TimeFenceDate datetime
Declare @Done bit



	Delete from #Items where ISNULL(RunID,@RunId)<>@RunId  --exclude items with onhand qty when MRP data was generated
	
	--Period def date list 
	Create table #DateList
	(
		PdId int identity(1, 1),
		IncDate datetime, DaysInPd int
	)

	--period qty buckets
	Create table #PdQtys
	(
		ItemId pItemId,
		LocId pLocId,
		PdDate datetime Null, 
		OnHand pDecimal default(0),
		SoCmtd pDecimal default(0), 
		MfCmtd pDecimal default(0), 
		MpCompReq pDecimal default(0),
		MfCompReq pDecimal default(0),
		MpOnOrder pDecimal default(0), 
		PoOnOrder pDecimal default(0),
		PoPurReq pDecimal default(0),
		WmOnOrder pDecimal default(0),
		JcCmtd pDecimal default(0),
		ProjOnHand pDecimal default(0),
		PlanRcpts pDecimal default(0),
		PlanOrdDate datetime null,		
		NetAvail pDecimal default (0),
		WorkOrderComponent pDecimal Default(0),
		WorkOrder pDecimal Default(0),
		MasterScheduledProduction pDecimal Default(0)
	)CREATE  INDEX [IX_ItemIdLocIdPdDate] ON [#PdQtys]([ItemId], [LocId], [PdDate])

	--set date for prior/last period
	Select @LateDate = dateadd(dd, -1, @WksDate)

Declare @NextDate datetime
Declare @tmpDate datetime
Declare @rowCount Int
Declare @rowNo Int

	Set @NextDate = @WksDate
	Select ROW_NUMBER() OVER (ORDER BY IncUnit) AS 'RowNumber', Increment,IncUnit 
	into #tmptblDrPeriodDefDtl 
	from dbo.tblDrPeriodDefDtl 
	Where PdDefId = @PdDefId

    Select @rowCount= COUNT(1) from #tmptblDrPeriodDefDtl 
    Set @rowNo=1
    
    While (@rowNo<=@rowCount)
    Begin
    Select @tmpDate= Case IncUnit
			When 1 Then DateAdd(ww, Increment, @NextDate) --weekly
			When 2 Then DateAdd(mm, Increment, @NextDate) --monthly
			Else DateAdd(dd, Increment, @NextDate) --daily
			End from #tmptblDrPeriodDefDtl where RowNumber = @rowNo
    
		Insert Into #DateList(IncDate, DaysInPd) values(@NextDate, Datediff(dd, @NextDate, @tmpDate))

		Select @NextDate = @tmpDate
        Set  @rowNo=@rowNo+1
    End
	--add @LateDate buckets at end of table so it's not included as a time fence period
	Insert into #DateList (IncDate, DaysInPd) Values (@LateDate, 1)

	Insert into #PdQtys(ItemId, LocId, PdDate, SOCmtd, MfCmtd, MpCompReq, MfCompReq
		, MpOnOrder, PoOnOrder, PoPurReq, WmOnOrder, JcCmtd)
	Select t.ItemId, t.LocId, d.IncDate
		, Sum(Case When t.Source = 16 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 32 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 8 Then t.Qty when t.Source = 512 Then t.Qty Else 0 End)
		, Sum(Case When t.Source = 64 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 4 Then t.Qty When t.Source = 256 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 1 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 2 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 1024 Then t.Qty Else 0 End) 
		, Sum(Case When t.Source = 2048 Then t.Qty Else 0 End) 
		From #DateList d, (Select r.ItemId, r.LocId
			, Case When r.TransDate < @WksDate Then @LateDate Else r.TransDate End TransDate
			, r.Source, r.Qty
			From dbo.tblDRRunData r inner join #Items i
			on r.ItemId = i.ItemId and r.LocId = i.LocId
			Where r.RunId = @RunId 
		) t
	Where t.TransDate Between d.IncDate and dateadd(dd, d.DaysInPd - 1, d.IncDate)
	Group By t.ItemId, t.LocId, d.IncDate

	--pack table to ensure records exist for each #DateList period
	Insert into #PdQtys(ItemId, LocId, PdDate) 
		Select i.ItemId, i.LocId, d.IncDate 
		From #DateList d, #Items i
		Where d.IncDate not in (Select PdDate From #PdQtys q Where q.ItemId = i.ItemId and q.LocId = i.LocId)

	If @ShowPriorYn <> 1 
	Begin
		--if not including prior periods then remove from dataset to prevent inclusion in calc
		Delete #PdQtys Where PdDate = @LateDate
	End

	--calcualte the Net Avail per period
	--	must find the respective date for the given time fence periods 
	--	to determine usage of actual vs forecasted quantity values
	Select  @TimeFencePds = TimeFencePds
		From dbo.tblDrPeriodDef
		Where PdDefId = @PdDefId

	Set @TimeFenceDate = Null

	Select @TimeFenceDate = Max(IncDate)
		From #DateList
		Where PdId <= @TimeFencePds    
	
	--if on first pass or if negative projected on hand qtys exist
	Set @Done = 0
	While @Done = 0
	Begin
		Update #PdQtys Set #PdQtys.NetAvail = (i.QtyOnHand - (l.QtySafetyStock*p.ConvFactor)) + tmp.NetAvail
		From (Select d.ItemId, d.LocId, d.PdDate
			, (Select Sum(PlanRcpts + MpOnOrder + PoOnOrder + PoPurReq + WmOnOrder
				- Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)
					Then  --larger of frcst vs sales
						Case When isnull(MfCmtd, 0) > (isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
							Then isnull(MfCmtd, 0)
							Else (isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
							End
					Else  --sales
						(isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
					End
				- Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)
					Then  --larger of Mstr Sched vs Act Prod Ord
						Case When isnull(MfCompReq, 0) > isnull(MpCompReq , 0)
							Then isnull(MfCompReq, 0)
							Else isnull(MpCompReq, 0)
							End
					Else  --Act Prod Ord
						isnull(MpCompReq, 0)
					End
				)
				From #PdQtys q
				Where q.ItemId = d.ItemId and q.LocId = d.LocId and q.PdDate <= d.PdDate) NetAvail 
			From #PdQtys d) tmp
			left join #Items i on tmp.ItemId = i.ItemId and tmp.LocId = i.LocId
			inner join dbo.tblInItemLoc l on i.ItemId = l.ItemId and i.LocId = l.LocId
			INNER JOIN dbo.tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
		Where #PdQtys.ItemId = tmp.ItemId and #PdQtys.LocId = tmp.LocId and #PdQtys.PdDate = tmp.PdDate	
		
		
		
	    --update the On Hand quantity for each Period
		--adjust each active period
		Update #PdQtys Set #PdQtys.OnHand = isnull(tmp.OnHand, (i.QtyOnHand - (l.QtySafetyStock*p.ConvFactor)))
		From #Items i 
		inner join dbo.tblInItemLoc l 
		on i.ItemId = l.ItemId and i.LocId = l.LocId
		INNER JOIN dbo.tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
		left join (Select d.ItemId, d.LocId, d.PdDate
			, (Select Top 1 NetAvail From #PdQtys q
				Where q.ItemId = d.ItemId and q.LocId = d.LocId and q.PdDate < d.PdDate
				Order by q.PdDate Desc) OnHand
			From #PdQtys d) tmp
		on i.ItemId = tmp.ItemId and i.LocId = tmp.LocId
		Where #PdQtys.ItemId = tmp.ItemId and #PdQtys.LocId = tmp.LocId and #PdQtys.PdDate = tmp.PdDate

		--Move the temp calculated NetAvail into the Projected On Hand
		Update #PdQtys Set ProjOnHand = NetAvail

		--initially set the loops' 'done' flag to true
		Set @Done = 1

		--if negative Projected on hand qtys exist - generate planned receipts and loop to recalc values
		-- Can't generate planned receipts earlier the start date
		If (Select Count(1) From #PdQtys Where ProjOnHand < 0 And (PdDate > @LateDate)) > 0
		Begin
			--set the planned order date for the respective periods to generate planned receipts for
			-- and Adjust the planned receipts and loop to recalc
			Update #PdQtys Set PlanOrdDate = DateAdd(dd, -isnull(calc.DfltLeadTime, 0), calc.PdDate)
				, #PdQtys.PlanRcpts = Case When abs(#PdQtys.ProjOnHand) > isnull(calc.QtyOrderMin*calc.ConvFactor, 0) Then abs(#PdQtys.ProjOnHand) Else isnull(calc.QtyOrderMin*calc.ConvFactor, 0) End
				From (Select q.ItemId, q.LocId, l.DfltLeadTime, l.QtyOrderMin, Min(q.PdDate) PdDate, p.ConvFactor
					From #PdQtys q inner join dbo.tblInItemLoc l
					on q.ItemId = l.ItemId and q.LocId = l.LocId
					INNER JOIN dbo.tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
					Where q.ProjOnHand < 0 And (PdDate > @LateDate)
					Group By q.ItemId, q.LocId, l.QtyOrderMin, l.DfltLeadTime, p.ConvFactor
				) calc
				Where #PdQtys.ItemId = calc.ItemId and #PdQtys.LocId = calc.LocId 
					and #PdQtys.PdDate = calc.PdDate

			Set @Done = 0
		End
	End

	
	Delete #PdQtys Where PdDate = @LateDate


	Select d.ItemId, d.LocId, i.Descr, Cast(l.DfltLeadTime as float) LeadTime
		,d.PdDate, d.PlanOrdDate
		,d.PlanRcpts / s.ConvFactor  as  Qty
		,l.EOQ * p.ConvFactor / s.ConvFactor  as EOQQty
		,l.QtyOrderMin * p.ConvFactor / s.ConvFactor as  MinQty
		,l.QtyOnHandMax * p.ConvFactor / s.ConvFactor  as   MaxQty
		,s.Uom as Unit
	From #Items s inner join #PdQtys d on s.ItemId = d.ItemId and s.LocId = d.LocId
	Inner Join dbo.tblInItemLoc l on s.ItemId = l.ItemId and s.LocId = l.LocId
	INNER JOIN dbo.tblInItemUom p ON l.ItemId = p.ItemId AND p.Uom = l.OrderQtyUom
	Inner join dbo.tblInItem i on s.ItemId = i.ItemId
	Where isnull(d.PlanRcpts, 0) > 0 
	Order by d.ItemId, d.LocId, d.PdDate


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPlannedProduction_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrPlannedProduction_proc';


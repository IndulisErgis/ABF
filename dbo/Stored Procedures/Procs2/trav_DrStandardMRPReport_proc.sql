
Create procedure trav_DrStandardMRPReport_proc  
@PdDefId nvarchar(10),  
@StartDate Datetime,  
@IncludeItems tinyint = 0, --2=All, 1=Active, 0=Required  
@ShowPriorYn bit = 1,  
@ShowFutureYn bit = 1,  
@ShowPlannedRcptsYn bit = 1,  
@PrecQty tinyint = 4, 
@PrecUCost tinyint = 4,
@RptCols int=12,
@RunId pPostRun ='All'
   
As  

SET NOCOUNT ON  

BEGIN TRY
--1=PurchOrds / 2=PurchReqs / 4=ProdOrds / 8=ProdOrdComp / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 1024=WM Transfer / 2048=JC Estimates  
--Standard MRP Report  
  
	Declare @LateDate datetime  
	Declare @TimeFencePds smallint  
	Declare @TimeFenceDate datetime  
	Declare @Done bit  
	Declare @FutureDate datetime  

	  
	--build temp table to hold base item info for items within selected range  
	Create table #Items  
	(  
	ItemId pItemId Not Null,   
	LocId pLocId Not Null,  
	DfltLeadTime pDecimal Default(0),   
	QtyOrderMin pDecimal Default(0),   
	QtySafetyStock pDecimal Default(0),  
	QtyOnHand pDecimal Default(0)  
	)  
	create clustered index ClstIdxItems on #items (ItemId, LocID)
	    
	--Period def date list   
	Create table #DateList(PdId int identity(1, 1), IncDate datetime, DaysInPd int)  
	  
	--period qty buckets  
	Create table #PdQtys  
	(  
	ItemId pItemId Not Null,  
	LocId pLocId Not Null,  
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
	NetAvail pDecimal default (0)  
	)  
	CREATE  INDEX [IX_PdDate] ON [#PdQtys]([PdDate])  
	  
	 
	  
	Select @FutureDate = cast('dec 31, 2399' as datetime)  
	  

	Exec trav_DrQryPdDefBuildDateList @PdDefId, @StartDate  

	  
	  
	--set date for prior/last period  
	Select @LateDate = dateadd(dd, -1, @StartDate)  
	Select @FutureDate = max(Dateadd(dd, DaysInPd, IncDate)) From #DateList
	SELECT @FutureDate = ISNULL(@FutureDate, @StartDate)
	  
	--add @LateDate buckets at end of table so it's not included as a time fence period  
	Insert into #DateList (IncDate, DaysInPd) Values (@LateDate, 1)  
	Insert into #DateList (IncDate, DaysInPd) Values (@FutureDate, 1)  
	  
	 
	--capture list of selected item information (capture base quantity values)  
	Insert into #Items (ItemId, LocId, DfltLeadTime, QtyOrderMin, QtySafetyStock, QtyOnHand)  
	Select i.ItemId, l.LocId, isnull(l.DfltLeadTime, 0)  
	 , isnull(l.QtyOrderMin * p.ConvFactor, 0), isnull(l.QtySafetyStock * p.ConvFactor, 0)  
	 , isnull(r.QtyOnHand, 0)  
	 From dbo.tblInItem i  
	 inner join dbo.tblInItemLoc l 
	   on i.ItemId = l.ItemId 
	 inner join  #tmp_StandardMrpReportFilter f
		on l.ItemId= f.ItemId and l.LocId =  f.LocId
	 Left Join dbo.tblInItemUom p   
	  on l.ItemId = p.ItemId AND l.OrderQtyUom = p.Uom  
	 Left Join dbo.tblDRRunItemLoc r  
	  on l.ItemId = r.ItemId and l.LocId = r.LocId  
	   where i.KittedYN=0 and i.ItemType <>3
	  

	--if only showing items that have activity (Active)  
	-- purge those that don't have any transactional activity  
	-- within the defined date range (exclude prior and future periods)  
	If @IncludeItems = 1  
	Begin  
	 
	  
	 Delete #Items   
	  Where Not Exists (Select 1 From dbo.tblDRRunData r   
	   Where r.RunId = @RunId  
		And r.ItemId = #Items.ItemId and r.LocId = #Items.LocId  
		And r.TransDate >= @StartDate and r.TransDate < @FutureDate)  
	  

	End  
	  
	--capture bucketed quantities 
	--1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256=WorkOrds / 512=WorkOrdComp / 1024=WM Transfer / 2048=JC Estimates  
	-- 4=ProdOrds / 8=ProdOrdComp 
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
	   , Case When convert(datetime, convert(varchar(10),  r.TransDate, 101)) < @StartDate Then @LateDate Else   
		Case When convert(datetime, convert(varchar(10),  r.TransDate, 101)) >= @FutureDate Then @FutureDate Else convert(datetime, convert(varchar(10),  r.TransDate, 101)) End End TransDate 
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
	 
	 --if not showing on report then remove from dataset  
	 Delete #PdQtys Where PdDate = @LateDate  

	End  
	  
	If @ShowFutureYn <> 1   
	Begin  
	 
	 --if not showing on report then remove from dataset  
	 Delete #PdQtys Where PdDate >= @FutureDate  
	 
	End  
	
	Create Index idx_ItemIdLocIdPDate on #PdQtys (ItemId, LocId, PdDate)
	
	--calcualte the Net Avail per period  
	-- must find the respective date for the given time fence periods   
	-- to determine usage of actual vs forecasted quantity values  
	Select @TimeFencePds = TimeFencePds  
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
	 Update #PdQtys Set #PdQtys.NetAvail = (i.QtyOnHand - i.QtySafetyStock) + tmp.NetAvail  
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
	 Where #PdQtys.ItemId = tmp.ItemId and #PdQtys.LocId = tmp.LocId and #PdQtys.PdDate = tmp.PdDate  
	  
	  
	 --update the On Hand quantity for each Period  
	 --adjust each active period  
	 Update #PdQtys Set #PdQtys.OnHand = isnull(tmp.OnHand, (i.QtyOnHand - i.QtySafetyStock))  
	 From #Items i   
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
	 -- Can't generate planned receipts earlier than the start date  
	 If @ShowPlannedRcptsYn = 1 and (Select Count(1) From #PdQtys Where ProjOnHand < 0 And (PdDate > @LateDate)) > 0  
	 Begin  
	  --set the planned order date for the respective periods to generate planned receipts for  
	  -- and Adjust the planned receipts and loop to recalc  
	  Update #PdQtys Set PlanOrdDate = DateAdd(dd, -isnull(calc.DfltLeadTime, 0), calc.PdDate)  
	   , #PdQtys.PlanRcpts = Case When abs(#PdQtys.ProjOnHand) > isnull(calc.QtyOrderMin, 0) Then abs(#PdQtys.ProjOnHand) Else isnull(calc.QtyOrderMin, 0) End  
	   From (Select q.ItemId, q.LocId, i.DfltLeadTime, i.QtyOrderMin, Min(q.PdDate) PdDate  
		From #PdQtys q inner join #Items i  
		on q.ItemId = i.ItemId and q.LocId = i.LocId  
		Where q.ProjOnHand < 0 And (PdDate > @LateDate)  
		Group By q.ItemId, q.LocId, i.QtyOrderMin, i.DfltLeadTime  
	   ) calc  
	   Where #PdQtys.ItemId = calc.ItemId and #PdQtys.LocId = calc.LocId   
	   and #PdQtys.PdDate = calc.PdDate  
	  
	  
	  
	  Set @Done = 0  
	 End  
	End  
	  
	--realign the ProjOnHand to exclude Planned Receipts for the given period date  
	-- (done to show the ProjOnHand that caused the generation of the receipt)  
	Update #PdQtys Set #PdQtys.ProjOnHand = (i.QtyOnHand - i.QtySafetyStock) + tmp.NetQtys + isnull(tmp.PriorRcpts, 0)  
	From #Items i  
	Left Join (Select d.ItemId, d.LocId, d.PdDate  
	 , (Select Sum(PlanRcpts) From #PdQtys q Where q.itemId = d.ItemId and q.LocId = d.LocId And q.PdDate < d.PdDate) PriorRcpts  
	 , (Select Sum(MpOnOrder + PoOnOrder + PoPurReq + WmOnOrder  
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
	  Where q.itemId = d.ItemId and q.LocId = d.LocId And q.PdDate <= d.PdDate) NetQtys  
	 From #PdQtys d) tmp  
	on i.ItemId = tmp.ItemId and i.LocId = tmp.LocId  
	Where #PdQtys.ItemId = tmp.ItemId And #PdQtys.LocId = tmp.LocId And #PdQtys.PdDate = tmp.PdDate  

	  
	--if only showing items that have planned orders (Required)  
	-- purge those that don't have any planned order dates  
	-- within the defined date range (exclude prior and future periods)  
	If @IncludeItems = 0  
	Begin  
	 
	  
	 Delete #Items   
	  Where Not Exists (Select 1 From #PdQtys q   
	   Where q.ItemId = #Items.ItemId and q.LocId = #Items.LocId  
		And (Not(q.PlanOrdDate is null) OR ProjOnHand < 0)
		And q.PdDate >= @StartDate and q.PdDate < @FutureDate)  

	End  
	 
	 --temp table for holding resultset
	 CREATE TABLE #tmpDrStandardMRP 
	 (
		[Counter] [int] IDENTITY(1,1) NOT NULL,
		[ItemID] [dbo].[pItemID] NOT NULL,
		[LocID] [dbo].[pLocID] NOT NULL,
		[OriOnHand] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[PdDate] [datetime] NULL,
		[OnHand] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[SoCmtd] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[MfCmtd] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[MpCompReq] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[MfCompReq] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[MpOnOrder] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[PoOnOrder] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[PoPurReq] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[WmOnOrder] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[JcCmtd] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[ProjOnHand] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[PlanRcpts] [dbo].[pDecimal] NOT NULL DEFAULT ((0)),
		[PlanOrdDate] [datetime] NULL,
		[FutureDate] [datetime] NULL,
		[StartDate] [datetime] NULL,
		[TimeFencePds] [smallint] NULL DEFAULT ((0))
	 )
	 
	 
	--Push the resultset  with quantities in Base UOM  
	Insert into #tmpDrStandardMRP (ItemID, LocID, OriOnHand  
	 , PdDate, OnHand, SoCmtd, MfCmtd, MpCompReq, MfCompReq, MpOnOrder  
	 , PoOnOrder, PoPurReq, ProjOnHand, PlanRcpts  
	 , PlanOrdDate, FutureDate, StartDate, TimeFencePds  
	 , WmOnOrder, JcCmtd)  
	Select d.ItemId, d.LocId, i.QtyOnHand  
	 , d.PdDate, d.OnHand, d.SoCmtd, d.MfCmtd, d.MpCompReq, d.MfCompReq, d.MpOnOrder  
	 , d.PoOnOrder, d.PoPurReq, d.ProjOnHand, d.PlanRcpts  
	 , d.PlanOrdDate, @FutureDate, @StartDate, @TimeFencePds  
	 , d.WmOnOrder, d.JcCmtd  
	From #PdQtys d Inner Join #Items i   
	 on d.ItemId = i.ItemId and d.LocId = i.LocId  
	Order by d.ItemId, d.LocId, d.PdDate  


	--Resultset 0

	Select t.ItemId, t.LocId LocationId, i.Descr  Description, l.DfltVendId DefaultVendor, l.DfltLeadTime  DefaultLeadTime  
	 ,i.UomDflt Unit  
	 , l.CostStd * Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End StandardCost  
	 , l.EOQ * Case When isnull(p.ConvFactor, 0) = 0 Then 1 Else p.ConvFactor End / Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End EOQ  
	 , t.OriOnHand / Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End OnHand  
	 , l.QtySafetyStock * Case When isnull(p.ConvFactor, 0) = 0 Then 1 Else p.ConvFactor End / Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End SafetyStock  
	 , l.QtyOrderMin * Case When isnull(p.ConvFactor, 0) = 0 Then 1 Else p.ConvFactor End / Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End MinOrderQty  
	 From (Select ItemId, LocId, OriOnHand  
	   From  #tmpDrStandardMRP
	   Group By ItemId, LocId, OriOnHand) t   
	 Inner Join dbo.tblInItem i   
	  on t.ItemId = i.ItemID  
	 Inner join dbo.tblInItemLoc l   
	  on t.ItemId = l.ItemId and t.LocId = l.LocId  
	 Left JOIN dbo.tblInItemUom p   
	  ON p.ItemId = l.ItemId AND p.Uom = l.OrderQtyUom  
	 Left join dbo.tblInItemUom u   
	  on i.ItemId = u.ItemId and i.UomDflt = u.UOM
	  
	  --Resultset 1
	  
	 Select cast((PdId - 1) / @RptCols as int) RepeatNum
			From #DateList
		Group by cast((PdId - 1) / @RptCols as int)
	  
	  
	  
	 --Resultset 2
	 
	 Select d.ItemId, d.LocId LocationId, c.Uom, c.ConvFactor  
	 , d.PdDate PeriodDate, d.FutureDate, d.StartDate  
	 , d.OnHand / c.ConvFactor OnHand  
	 , (d.SoCmtd + d.JcCmtd) / c.ConvFactor SalesOrders --combine SO & JC for reporting  
	 , d.MfCmtd / c.ConvFactor SalesForecasts  
	 , d.MpCompReq / c.ConvFactor ComponentRequirements  
	 , d.MfCompReq / c.ConvFactor MSCompRequirements  
	 , d.MpOnOrder / c.ConvFactor ProductionOrders  
	 , (d.PoOnOrder + d.WmOnOrder) / c.ConvFactor PurchaseOrders --combine PO & WM for reporting  
	 , d.PoPurReq / c.ConvFactor PurchaseRequisitions  
	 , d.ProjOnHand / c.ConvFactor ProjectedOnHand  
	 ,d.PlanRcpts / c.ConvFactor PlannedReceipts  
	 , d.PlanOrdDate PlannedOrderDate  
	From #tmpDrStandardMRP d  
	Left join (Select i.ItemId, u.UOM  
	  , Case when isnull(u.ConvFactor, 0) = 0 Then 1 else u.ConvFactor End ConvFactor  
	  From dbo.tblInItem i  
	  Left Join dbo.tblInItemUom u   
	  on i.ItemId = u.ItemId and i.UomDflt = u.UOM) c  
	 on d.ItemId = c.ItemId  
	Order by d.ItemId, d.LocId, d.PdDate
	 
 
END TRY
BEGIN CATCH
      EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrStandardMRPReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrStandardMRPReport_proc';


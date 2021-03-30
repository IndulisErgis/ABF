
Create procedure dbo.trav_DrMasterScheduleReport_proc 
(
@PeriodDefinitionId nvarchar(10),
@StartDate DateTime,
@PrecQty decimal,
@RptCols int=12,
@SoYn bit = 0,
@JcYn bit = 0,
@ShowPriorYn bit = 1,
@ShowFutureYn bit = 1
)
As
Begin Try
SET NOCOUNT ON
Declare @SOBMYn bit
Select @SOBMYn = Case When Count(*) > 0 Then 1 Else 0 End From dbo.tblSmApp_Installed Where AppId = 'BM'
 
	Select m.AssemblyId, m.LocId, m.UOM, i.Descr into #tmptblDrMasterScheduleReport
	From #tmpRptItems t inner join dbo.tblDrMstrSched m on t.LocId=m.LocID
	inner join dbo.tblInItem i
	on m.AssemblyId = i.ItemId and t.ItemID=i.ItemId and  isnull(t.ProductLine,'')=isnull(i.ProductLine,'')
	And
	(Exists (Select 1 From dbo.tblSoTransDetail t 
			Where @SoYn = 1 and t.ItemId = m.AssemblyId and t.LocId = m.LocId AND t.Status = 0 
			Group By ItemId) --pending SO Transactions
	or Exists (Select 1 From dbo.tblDrFrcst f Inner Join dbo.tblInItem i 
			on f.ItemId = i.ItemId 
			Where f.ItemId = m.AssemblyId and f.LocId = m.LocId and i.KittedYn = 0) --non-kitted forecast
	or Exists (Select 1 From dbo.tblDrFrcst f Inner Join dbo.tblInItem i
			on f.ItemId = i.ItemId 
			Inner Join dbo.tblBmBom h 
			on f.ItemId = h.BmItemId and f.LocId = h.BmLocId
			Inner Join dbo.tblBmBomDetail d
			on h.BmBomId = d.BmBomId
			Where d.ItemId = m.AssemblyId and d.LocId = m.LocId and i.KittedYn <> 0) --kitted forecast component detail
	OR EXISTS (SELECT 1 FROM dbo.tblSoSaleBlanket h 
			Inner join dbo.tblSoSaleBlanketDetail d on h.BlanketRef = d.BlanketRef
			Inner Join dbo.tblSoSaleBlanketDetailSch s On d.BlanketDtlRef = s.BlanketDtlRef 
			Where h.BlanketType = 2 And h.BlanketStatus = 0 AND s.Status = 0 --Line Item - scheduled and open with new qty status
				AND d.ItemId = m.AssemblyId AND d.LocId = m.LocID) 

	OR EXISTS (SELECT 1 FROM dbo.tblSoSaleBlanket h
			Inner join dbo.tblSoSaleBlanketDetail d on h.BlanketRef = d.BlanketRef
			Inner Join dbo.tblInItem i on d.ItemId = i.ItemId
			Inner Join dbo.tblSoSaleBlanketDetailSch s On d.BlanketDtlRef = s.BlanketDtlRef
			Inner Join dbo.tblBmBom b on d.ItemId = b.BmItemId and d.LocId = b.BmLocId
			Inner Join dbo.tblBmBomDetail k on b.BmBomId = k.BmBomId
			Where h.BlanketType = 2 And h.BlanketStatus = 0 --scheduled and open
				AND i.ItemType <> 3 and i.KittedYn <> 0 --inventoried and kitted item
				AND s.Status = 0 --valid quantity with new status
				AND @SOBMYn = 1 
				AND k.ItemId = m.AssemblyId AND k.LocId = m.LocID) --kitted blanket item component detail

	OR EXISTS (Select 1 From dbo.tblPcEstimate t inner join tblPcTrans P on t.ProjectDetailId=p.ProjectDetailId --JC Project Estimates
			Where @JcYn = 1 And t.ResourceId = m.AssemblyId and t.LocId = m.LocId and isnull(P.QtySeqNum,0)<>0 )
		)
		
	--Main Report OutPut 	
	Select AssemblyId, LocId LocationID, UOM 'UNIT', Descr  'Description' from #tmptblDrMasterScheduleReport	
	

----*********************************************  Subreport 1  ***********************************************

		Declare @NextDate datetime
		Declare @tmpDate DateTime
		Declare @LateDate DateTime
		Declare @FutureDate Datetime
		Declare @rowCount Int
		Declare @rowNo Int		
		Declare @QtyOnHand pDecimal
		Declare @TimeFencePds smallint
		Declare @TimeFenceDate datetime
		
				
		Declare @CurDate datetime
		Declare @Ctr int
		Declare @FixedCols int

		set @FixedCols=cast(@ShowPriorYn as int) + cast(@ShowFutureYn as int)

		Create table #DateList1(PdId int identity(1, 1), IncDate datetime, DaysInPd int)
		Select @CurDate = GetDate()
		Select @RptCols = case When @RptCols < 1 then 1 Else @RptCols End

		Select  ROW_NUMBER() OVER (ORDER BY IncUnit) AS 'RowNumber',Increment, IncUnit into #tmptblDrPeriodDefDtl1
		From dbo.tblDrPeriodDefDtl
		Where PdDefId = @PeriodDefinitionId
		Order By Period
		
		Select @rowCount= COUNT(1) from #tmptblDrPeriodDefDtl1 
		Set @rowNo=1
		Set @NextDate= @CurDate
		While (@rowNo<=@rowCount)
		Begin
		Select @tmpDate= Case IncUnit
				When 1 Then DateAdd(ww, Increment, @NextDate) --weekly
				When 2 Then DateAdd(mm, Increment, @NextDate) --monthly
				Else DateAdd(dd, Increment, @NextDate) --daily
				End from #tmptblDrPeriodDefDtl1 where RowNumber = @rowNo
	    
			Insert Into #DateList1(IncDate, DaysInPd) values(@NextDate, Datediff(dd, @NextDate, @tmpDate))

			Select @NextDate = @tmpDate
			Set  @rowNo=@rowNo+1
		End
 
		if @FixedCols > 0
		Begin
			Set @Ctr = 0
			While @Ctr < @FixedCols
			Begin
				Insert into #DateList1(IncDate) values (@curDate)
				Set @Ctr = @Ctr + 1
			End
		End
 		--return a resultset for duplicating the row labels on reports with an unlimited number of repeating columns
		Select cast((PdId - 1) / @RptCols as int) RepeatNum
			From #DateList1
		Group by cast((PdId - 1) / @RptCols as int)


----*********************************************  Subreport 1  ***********************************************	
		
----*********************************************  Subreport 2  ***********************************************	
		
		--build temp table for capturing transactional qty transactions
		Create table #Trans
		(
			ItemID pItemID,
			LocID  nvarchar(10),
			UOM nvarchar(10),
			[TransDate] [datetime] Not NULL,
			[TransType] [tinyint] NOT NULL , --0=committed / 2=on order
			[Source] [smallint] Not Null, --16=SalesOrds / 32=FrcstSales / 128=MstrSchedProduction / 256=WorkOrds
			[VirtualYn] bit Not Null default(0),  --=1 for virtual trans from Sales Forecasts and Master scheduled production
			[Qty] [pDecimal] NOT NULL DEFAULT (0),
		)
		
		--Period def date list 
		Create table #DateList
		(
			PdId int identity(1, 1), 
			IncDate datetime, DaysInPd int
		)
		
		--period qty buckets
		Create table #PdQtys
		(
			ItemID pItemID,
			LocID   nvarchar(10),
			UOM nvarchar(10),
			PdDate datetime Null, 
			OnHand pDecimal default(0),
			SoCmtd pDecimal default(0), 
			JcCmtd pDecimal default(0),
			DrCmtd pDecimal default(0), 
			BmOnOrder pDecimal default(0), 
			DrOnOrder pDecimal default(0),
			NetAvail pDecimal default (0)
		)
		
		Create table #QtyOnHand
		(
			ItemID pItemID,
			LocID  pLocID,
			QtyOnHand pDecimal
		)

		Select  ROW_NUMBER() OVER (ORDER BY IncUnit) AS 'RowNumber',Increment, IncUnit into #tmptblDrPeriodDefDtl
		From dbo.tblDrPeriodDefDtl
		Where PdDefId = @PeriodDefinitionId
		Order By Period
		Set @NextDate= @StartDate
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
 		--set date for prior/last period
		Select @LateDate = dateadd(dd, -1, @StartDate)
		Select @FutureDate = max(Dateadd(dd, DaysInPd, IncDate)) From #DateList
		
		--add @LateDate buckets at end of table so it's not included as a time fence period
		Insert into #DateList (IncDate, DaysInPd) Values (@LateDate, 1)
		Insert into #DateList (IncDate, DaysInPd) Values (@FutureDate, 1)		
		
		SELECT ItemId, LocId, cast(Sum(Qty - InvoicedQty - RemoveQty) as float) AS QtyOnHand, 
				cast(Sum((Qty - InvoicedQty - RemoveQty) * Cost) as float) AS Cost into #tmpInItemOnHand
		FROM dbo.tblInQtyOnHand
		GROUP BY ItemId, LocId		
 
		SELECT ItemId, LocId, cast(SUM(CASE SerNumStatus WHEN 5 THEN 0 ELSE 1 END) as float) AS QtyOnHand, 
			cast(SUM(CASE SerNumStatus WHEN 2 THEN 1 WHEN 5 THEN -1 ELSE 0 END) as float) AS QtyInUse,
			cast(SUM(CASE SerNumStatus WHEN 5 THEN 0 ELSE CostUnit END) as float) AS Cost into #tmpInItemOnHandSerSum
		FROM dbo.tblInItemSer
		WHERE (SerNumStatus = 1) OR
		(SerNumStatus = 2) OR (SerNumStatus = 5)
		GROUP BY ItemId, LocId
		
		--capture current on hand qty for non-serialized and serialized items	
		insert into #QtyOnHand select  tmp.AssemblyId,tmp.LocID,isnull(Sum(tmp.QtyOnHand), 0)
		From (Select R.AssemblyId,R.LocID,q.QtyOnHand
				From  #tmptblDrMasterScheduleReport R inner join dbo.#tmpInItemOnHand q
				on q.ItemId =R.AssemblyId and q.LocId =R.LocId			

				Union all

			 Select R.AssemblyId,R.LocID,(q.QtyOnHand - q.QtyInUse) QtyOnHand
				From  #tmptblDrMasterScheduleReport R  inner join dbo.#tmpInItemOnHandSerSum q
				on q.ItemId =R.AssemblyId and q.LocId =R.LocId
			
		) tmp group by tmp.AssemblyId,tmp.LocID

		--Reduce onhand by any inuse quantities for non-serialized	
	 
		Update    #QtyOnHand set  #QtyOnHand.QtyOnHand = isnull(#QtyOnHand.QtyOnHand,0)-isnull(t.qty, 0)
		From(Select R.assemblyID,R.LocID,isnull(Sum(q.Qty), 0) qty from #tmptblDrMasterScheduleReport R 
		inner join dbo.tblInQty q		on q.ItemId =R.AssemblyId And q.LocId =R.LocId 	
		Inner Join dbo.tblInItem i		on i.ItemId = q.ItemId
		inner join dbo.tblInItemLoc l	on q.ItemId = l.ItemId And q.LocId = l.LocId	
		inner join  #QtyOnHand H    On  R.AssemblyId=H.ItemID and R.LocID=H.LocID
		Where q.TransType = 1 and q.Qty <> 0
		 Group By  R.AssemblyId,R.LocID
		 ) t 
 
		--conditionally capture SO data
		If (@SoYn = 1) 
		Begin
		
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) < @StartDate Then @LateDate Else 
				Case When coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) >= @FutureDate Then @FutureDate
				Else coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) End End , q.TransType, 16, 0, q.Qty --16=SalesOrds
				From #tmptblDrMasterScheduleReport R 
				Inner join dbo.tblInQty q			On q.ItemId =R.AssemblyId And q.LocId =R.LocId 
				Inner join dbo.tblSoTransDetail d	On q.SeqNum = d.QtySeqNum_Cmtd
				Inner Join dbo.tblSoTransHeader t	On d.TransId = t.TransId 
				Where q.LinkId = 'SO' And q.TransType = 0 And q.Qty <> 0 And d.Status = 0			 


			--add extended quantity detail
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId ,Case When coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) < @StartDate Then @LateDate Else 
				Case When coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) >= @FutureDate Then @FutureDate 
				Else coalesce(d.ReqShipDate, t.ReqShipDate, t.TransDate) End End , q.TransType, 16, 0, q.Qty --16=SalesOrds
				From	#tmptblDrMasterScheduleReport R 
						Inner join dbo.tblInQty q				On q.ItemId =R.AssemblyId and q.LocId =R.LocId
						Inner join dbo.tblSoTransDetailExt e	On q.SeqNum = e.QtySeqNum
						Inner join dbo.tblSoTransDetail d		On e.TransId = d.TransId and e.EntryNum = d.EntryNum
						Inner Join dbo.tblSoTransHeader t		On d.TransId = t.TransId 
				Where q.LinkId = 'SO' And q.TransType = 0 And q.Qty <> 0 And d.Status = 0
 		 
			--add Scheduled Sale Blanket quantities (non-kitted item)
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When s.ReleaseDate < @StartDate Then @LateDate Else 
				Case When s.ReleaseDate >= @FutureDate Then @FutureDate Else s.ReleaseDate End End
				, 0, 16, 1 --16=SalesOrds (scheduled blankets mirror sales orders with VirtualYn = 1)
				, Round(s.QtyOrdered * u.ConvFactor, Case When i.ItemType = 2 Then 0 Else @PrecQty End) --round to whole units for serialized				
				From	dbo.tblSoSaleBlanket h
						Inner join dbo.tblSoSaleBlanketDetail d		On h.BlanketRef = d.BlanketRef
						Inner Join #tmptblDrMasterScheduleReport R  On d.ItemId =R.AssemblyId and d.LocId =R.LocId
						Inner Join dbo.tblInItem i					On d.ItemId = i.ItemId
						Inner Join dbo.tblSoSaleBlanketDetailSch s	On d.BlanketDtlRef = s.BlanketDtlRef
						Inner Join dbo.tblInItemUOM u				On d.ItemId = u.ItemId And d.Units = u.UOM
				Where h.BlanketType = 2 And h.BlanketStatus = 0 --scheduled and open
						And i.ItemType <> 3 And i.KittedYn = 0 --inventoried and non-kitted
						And s.QtyOrdered <> 0 And s.Status = 0 --valid quantity with new status
		 
				--add Scheduled Sale Blanket quantities (kit components item)
			If @SOBMYn = 1
			Begin
	 
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When s.ReleaseDate < @StartDate Then @LateDate Else 
					Case When s.ReleaseDate >= @FutureDate Then @FutureDate Else s.ReleaseDate End End
					, 0, 16, 1 --16=SalesOrds (scheduled blankets mirror sales orders with VirtualYn = 1)
					, Round((k.Quantity * u.ConvFactor) * (s.QtyOrdered * u.ConvFactor), Case When ic.ItemType = 2 Then 0 Else @PrecQty End) --round to whole units for serialized
					From	dbo.tblSoSaleBlanket h
							Inner join dbo.tblSoSaleBlanketDetail d		On h.BlanketRef = d.BlanketRef
							Inner Join dbo.tblInItem i					On d.ItemId = i.ItemId
							Inner Join dbo.tblSoSaleBlanketDetailSch s	On d.BlanketDtlRef = s.BlanketDtlRef
							Inner Join dbo.tblBmBom b					On d.ItemId = b.BmItemId And d.LocId = b.BmLocId
							Inner Join dbo.tblBmBomDetail k				On b.BmBomId = k.BmBomId
							Inner Join #tmptblDrMasterScheduleReport R  On k.ItemId =R.AssemblyId And k.LocId =R.LocId
							Inner Join dbo.tblInItem ic					On k.ItemId = ic.ItemId
							Inner Join dbo.tblInItemUOM u				On k.ItemId = u.ItemId And k.UOM = u.UOM
					Where h.BlanketType = 2 And h.BlanketStatus = 0 --scheduled and open
							And i.ItemType <> 3 And i.KittedYn <> 0 --inventoried and kitted item
							And s.QtyOrdered <> 0 And s.Status = 0 --valid quantity with new status
							And k.Quantity <> 0					
			End			
		End		
		
		If @JcYn = 1 
		Begin
		--capture any committed quantities for project estimates			
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When isnull(t.EstStartDate, @StartDate) < @StartDate Then @LateDate Else 
				Case When isnull(t.EstStartDate,@StartDate) >= @FutureDate Then @FutureDate Else isnull(t.EstStartDate, @StartDate) End End
				, q.TransType, 2048, 0, q.Qty --2048=JC Estimates
				From	#tmptblDrMasterScheduleReport R 
						Inner Join dbo.tblInQty q			On q.ItemId =R.AssemblyId And q.LocId =R.LocId 
						Inner Join dbo.tblPcEstimate d	    On d.ResourceId=q.ItemId and d.LocId=q.LocId
						Left  Join dbo.tblPcProjectDetail t	On d.ProjectDetailId = t.ProjectId 
						
				Where q.LinkId = 'JC' and q.TransType = 0 and q.Qty <> 0		
		End
		
		--capture BM data	
		--BM WorkOrders with real inventory transactions
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select q.AssemblyId,q.LocId , Case When t.TransDate < @StartDate Then @LateDate Else 
				Case When t.TransDate >= @FutureDate Then @FutureDate Else t.TransDate End End, q.TransType, 256, 0, q.Qty --256=WorkOrds
				From (	Select R.AssemblyId,R.LocId,q2.TransType, q2.LinkIdSub TransId, Cast(q2.LinkIdSubLine as int) EntryNum, q2.Qty
						From	#tmptblDrMasterScheduleReport R 
								Inner Join dbo.tblInQty q2 On q2.ItemId =R.AssemblyId And q2.LocId =R.LocId 
						Where q2.LinkId = 'BM' and q2.Qty <> 0 and q2.TransType = 2			
					 ) q
				Inner Join ( --capture on order qtys for assemblies being built
							Select  R.AssemblyId,R.LocId ,h.TransId, h.EntryNum, h.TransDate 
							From	#tmptblDrMasterScheduleReport R 
									Inner Join dbo.tblBmWorkOrder h  On h.ItemId =R.AssemblyId And h.LocId =R.LocId 
							Where h.WorkType = 1 
							Union All --capture on order qtys for components of assemblies being unbuilt
							Select R.AssemblyId,R.LocId ,d.TransId, d.EntryNum, h.TransDate 
							From	dbo.tblBmWorkOrder h 
									Inner Join dbo.tblBmWorkOrderDetail d		On h.TransId = d.TransId
									Inner Join #tmptblDrMasterScheduleReport R	On d.ItemId =R.AssemblyId And d.LocId =R.LocId 		
				) t
				On q.TransId = t.TransId and q.EntryNum = t.EntryNum 
				and q.AssemblyId=t.AssemblyId and q.LocId =t.locID
		 		
			--capture DR data
			--capture any sales forecasts - non-kitted forecasts
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When q.FrcstDate < @StartDate Then @LateDate Else 
				Case When q.FrcstDate >= @FutureDate Then @FutureDate Else q.FrcstDate End End, 0, 32, 1 --32=FrcstSales
				, Round(q.Qty * Case When isnull(u.ConvFactor, 0) = 0 Then 1 Else u.ConvFactor End, @PrecQty)
				From dbo.tblDrFrcst h 
					Inner Join dbo.tblDrFrcstDtl q 				on h.ID = q.frcstID
					Inner Join #tmptblDrMasterScheduleReport R	On h.ItemId =R.AssemblyId And h.LocId =R.LocId 
					Inner Join dbo.tblInItem i					On h.ItemId = i.ItemId
					Left  join dbo.tblInItemUOM u				On h.ItemId = u.ItemId and h.UOM = u.UOM
				Where q.Qty <> 0 and i.KittedYn = 0
				
			--capture sales forecasts for the components of kitted sales forecasts
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When fd.FrcstDate < @StartDate Then @LateDate Else 
				Case When fd.FrcstDate >= @FutureDate Then @FutureDate Else fd.FrcstDate End End
				, 0, 32, 1 --32=FrcstSales
				, Round((((fd.Qty * Case When isnull(u3.ConvFactor, 0) = 0 Then 1 Else u3.ConvFactor End) --use the base quantity of the forecast detail
				/ (Case When isnull(u1.ConvFactor, 0) = 0 Then 1 Else u1.ConvFactor End))  --convert forecast base qty into kit definition units
				* (d.Quantity * Case When isnull(u2.ConvFactor, 0) = 0 Then 1 Else u2.ConvFactor End)), @PrecQty) --expand the component qty in base units
				From dbo.tblBmBom h 
					Inner Join dbo.tblBmBomDetail d				On h.BmBomId = d.BmBomId
					Inner Join #tmptblDrMasterScheduleReport R	On d.ItemId =R.AssemblyId And d.LocId =R.LocId 
					Inner Join dbo.tblInItem i					On h.BmItemId = i.ItemId
					Inner Join dbo.tblDrFrcst f					On h.BmItemId = f.ItemId And h.BmLocId = f.LocId
					Inner Join dbo.tblDrFrcstDtl fd				On f.id = fd.FrcstId
					Left  Join dbo.tblInItemUom u1				On h.BmItemId = u1.ItemId And h.Uom = u1.Uom
					Left  Join dbo.tblInItemUom u2				On d.ItemId = u2.ItemId And d.Uom = u2.Uom
					Left  Join dbo.tblInItemUom u3				On f.ItemId = u3.ItemId And f.Uom = u3.Uom
				Where i.KittedYn <> 0 And d.Quantity <> 0
		
		
			--capture all master scheduled production quantities 
			Insert into #Trans (ItemID,LocID,  TransDate, TransType, Source, VirtualYn, Qty)
				Select R.AssemblyId,R.LocId , Case When q.ProdDate < @StartDate Then @LateDate Else 
				Case When q.ProdDate >= @FutureDate Then @FutureDate Else q.ProdDate End End
				, 2, 128, 1 --128=MstrSched production
				, Round(q.Qty * Case When isnull(i.ConvFactor, 0) = 0 Then 1 Else i.ConvFactor End, @PrecQty)
				From dbo.tblDrMstrSched h
					Inner Join dbo.tblDrMstrSchedDtl q			On h.id = q.mstrschedid
					Inner Join #tmptblDrMasterScheduleReport R	On h.AssemblyId =R.AssemblyId And h.LocId =R.LocId 
					left  join dbo.tblInItemUOM i 				On h.AssemblyId = i.ItemId And h.UOM = i.UOM		
					
	--************************************************************************************************************	
		--capture MP data		 
		----In Process or greater status - i.e. those with real inventory transactions	
		Insert into #Trans (ItemId,LocID,TransDate, TransType, Source, VirtualYn, Qty)
		Select q.ItemID,q.LocID, Case When t.EstCompletionDate < @StartDate Then @LateDate Else 
			Case When t.EstCompletionDate >= @FutureDate Then @FutureDate Else t.EstCompletionDate End End
			, q.TransType, 4, 0, q.Qty --4=ProdOrds
			From (Select q2.SeqNum, q2.ItemId,q2.LocId, q2.TransType, q2.LinkIdSub OrderNo, left(q2.LinkIdSubLine, 3) ReleaseNo, q2.Qty
				From dbo.tblInQty q2
				inner join #tmptblDrMasterScheduleReport R on q2.ItemId=R.AssemblyId and q2.LocId=R.LocId 
				Where q2.LinkId = 'MP' and q2.Qty <> 0 and q2.TransType = 2			
				) q
			Inner Join dbo.tblMpMatlSum s ON s.QtySeqNum = q.SeqNum
			INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId
			INNER JOIN dbo.tblMpOrderReleases t ON r.ReleaseId = t.Id
			Where (s.[Status] <> 6 and t.[Status] <> 6)
			 
	 
		--new/planned/firm planned/released (Status < 4)
		Insert into #Trans (ItemID,LocID,TransDate,TransType, Source, VirtualYn, Qty)
		Select R.AssemblyId , R.LocId , Case When t.EstCompletionDate < @StartDate Then @LateDate Else 
			Case When t.EstCompletionDate >= @FutureDate Then @FutureDate Else t.EstCompletionDate End End
			, 2, 4, 0 --2=OnOrder / 4=ProdOrds
			, Round(t.Qty * u.ConvFactor, @PrecQty)
			From #tmptblDrMasterScheduleReport R
			inner join dbo.tblMpOrder o on   o.AssemblyId =R.AssemblyId  and o.LocId = R.LocId
			inner join dbo.tblMpOrderReleases t on o.OrderNo = t.OrderNo
			Inner join (Select ItemId, UOM , Case When isnull(ConvFactor, 0) = 0 then 1 Else ConvFactor End ConvFactor 
					From dbo.tblInItemUOM) u
			On o.AssemblyId = u.ItemId and t.Uom = u.UOM
			Where t.Status < 4  	
							
 				
	--************************************************************************************************************		
			
			--capture bucketed quantities			
			Insert into #PdQtys(ItemID,LocID, PdDate, SOCmtd, JcCmtd, DrCmtd, BmOnOrder, DrOnOrder)
			Select t.ItemID,t.LocID, d.IncDate
			, Round(Sum(Case When t.Source = 16 Then t.Qty Else 0 End), @PrecQty)
			, Round(Sum(Case When t.Source = 2048 Then t.Qty Else 0 End), @PrecQty)
			, Round(Sum(Case When t.Source = 32 Then t.Qty Else 0 End), @PrecQty)
			, Round(Sum(Case When t.Source = 4 Then t.Qty When t.Source = 256 Then t.Qty Else 0 End), @PrecQty) 
			, Round(Sum(Case When t.Source = 128 Then t.Qty Else 0 End), @PrecQty)
			From #DateList d, #Trans t
			Where t.TransDate Between d.IncDate and dateadd(dd, d.DaysInPd - 1, d.IncDate)
			Group By t.ItemID,t.LocID, d.IncDate			 
	
			--pack table to ensure records exist for each #DateList period		
			insert into #PdQtys(ItemID,LocID,PdDate)
			select Distinct  Q.ItemID,Q.LocID,D.IncDate from #DateList D,#PdQtys Q 
			where D.IncDate not in (select Q1.PdDate from  #PdQtys Q1 Where Q1.ItemId = Q.ItemId and Q1.LocId = Q.LocId)	

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
						
			--  calcualte the Net Avail per period
			--	must find the respective date for the given time fence periods 
			--	to determine usage of actual vs forecasted quantity values
			Select @TimeFencePds = TimeFencePds
				From dbo.tblDrPeriodDef
				Where PdDefId = @PeriodDefinitionId
				
			Set @TimeFenceDate = Null

			Select @TimeFenceDate = Max(IncDate)
				From #DateList
				Where PdId <= @TimeFencePds    
		 
	
			Update #PdQtys Set #PdQtys.NetAvail = isnull(H.QtyOnHand,0) + isnull(tmp.NetAvail,0)
				From (Select D.ItemID,D.LocID,d.PdDate
					, (Select Sum(
						Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)
							Then  --larger of mstr sched vs prod ords
								Case When isnull(DrOnOrder, 0) > isnull(BmOnOrder , 0)
									Then isnull(DrOnOrder, 0)
									Else isnull(BmOnOrder, 0)
									End
							Else  --prod ords
								isnull(BmOnOrder, 0)
							End
						- Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)
							Then  --larger of frcst vs sales
								Case When isnull(DrCmtd, 0) > (isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
									Then isnull(DrCmtd, 0)
									Else (isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
									End
							Else  --sales
								(isnull(SoCmtd , 0) + isnull(JcCmtd , 0))
							End
						)
						From #PdQtys q
						Where q.ItemId = d.ItemId and q.LocId = d.LocId and q.PdDate <= d.PdDate ) NetAvail 
					From #PdQtys d) tmp   
					Left join #QtyOnHand H on tmp.ItemID=H.ItemID and tmp.LocId=H.LocID
				Where #PdQtys.PdDate = tmp.PdDate	and #PdQtys.ItemID = tmp.ItemID and #PdQtys.LocID=tmp.LocID		 		 
		 	 
				--update the On Hand quantity for each Period				
				--adjust each active period
				
				Update #PdQtys Set #PdQtys.OnHand = isnull(tmp.OnHand, isnull(H.QtyOnHand,0))
				From 
				 (Select d.PdDate,d.ItemID,d.LocID
					, (Select Top 1 NetAvail From #PdQtys q  
						 Where q.ItemId = d.ItemId and q.LocId = d.LocId and q.PdDate < d.PdDate  
						 Order by q.PdDate Desc) OnHand
					From #PdQtys d) tmp Left join  #QtyOnHand H
					on  tmp.ItemID=H.ItemId and tmp.LociD=H.LocID
				 Where #PdQtys.ItemId = tmp.ItemId and #PdQtys.LocId = tmp.LocId and #PdQtys.PdDate = tmp.PdDate  						
												
				--update the uOM for each item and Loc
				update  p set p.UOM = R.UOM  from #PdQtys P inner join #tmptblDrMasterScheduleReport R on  P.ItemID=R.AssemblyId and P.LocID=R.LocID
			 
				Select #PdQtys.ItemID AssemblyId, #PdQtys.LocID LocationId, @TimeFencePds TimeFencePds
					, @FutureDate FutureDate, @StartDate StartDate
					, #PdQtys.PdDate PeriodDate, Cast(Round(OnHand / ISNULL(U.ConvFactor,1), @PrecQty) as float) OnHand
					, Cast(Round(SoCmtd / ISNULL(U.ConvFactor,1), @PrecQty) as float)  'SalesOrders'
					, Cast(Round(JcCmtd / ISNULL(U.ConvFactor,1), @PrecQty) as float) JcCmtd
					, Cast(Round(SoCmtd /ISNULL(U.ConvFactor,1), @PrecQty) as float) 
								+ Cast(Round(JcCmtd / ISNULL(U.ConvFactor,1), @PrecQty) as float) SoJcCmtd --SO & JC combined for reporting
					, Cast(Round(DrCmtd /ISNULL(U.ConvFactor,1), @PrecQty) as float)  'SalesForecasts'
					, Cast(Round(BmOnOrder / ISNULL(U.ConvFactor,1), @PrecQty) as float) 'ProductionOrders'
					, Cast(Round(DrOnOrder / ISNULL(U.ConvFactor,1), @PrecQty) as float)  'MasterProdSchedule'
					, Cast(Round(NetAvail /ISNULL(U.ConvFactor,1), @PrecQty) as float) 'NetAvailable'
				from #PdQtys  Left outer join dbo.tblInItemUom U on  #PdQtys.ItemID=U.ItemId and #PdQtys.UOM=U.Uom 
				Order by #PdQtys.ItemID ,PdDate

----*********************************************  Subreport 2  ***********************************************	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrMasterScheduleReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrMasterScheduleReport_proc';


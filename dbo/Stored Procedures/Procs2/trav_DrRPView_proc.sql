
CREATE  Procedure [dbo].[trav_DrRPView_proc]        
@RunId pPostRun ='All',        
@ItemId pItemId,        
@LocId pLocId,        
@UOM pUOM,        
@PdDefId nvarchar(10),        
@StartDate Datetime,        
@ShowPriorYn bit = 1,        
@ShowFutureYn bit = 1,        
@PrecQty tinyint = 4,        
@LocIdALL bit = 0        
        
As          
        
SET NOCOUNT ON       
        
BEGIN TRY        
      
--1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256 WorkOrder / 512 WorkOrderComp / 1024=WM Transfer / 2048=JC Estimate        
--DRP Inquiry        
      
Declare @TimeFencePds smallint        
Declare @TimeFenceDate datetime        
Declare @QtyOnHand pDecimal        
Declare @ConvFactor pDecimal        
Declare @LateDate datetime        
Declare @FutureDate datetime        
Declare @QtySafetyStock pDecimal        
        
--Period def date list         
Create table #DateList(PdId int identity(1, 1), IncDate datetime, DaysInPd int)        
        
--period qty buckets        
Create table #PdQtys        
(        
PdDate datetime Null,         
OnHand pDecimal default(0),        
SoCmtd pDecimal default(0),         
DrCmtd pDecimal default(0),         
BmCompReq pDecimal default(0),        
DrCompReq pDecimal default(0),        
BmOnOrder pDecimal default(0),
WorkOder  pDecimal default(0),        
PoPurReq pDecimal default(0),        
PoOnOrder pDecimal default(0),        
WmOnOrder pDecimal default(0),        
JcCmtd pDecimal default(0),        
NetAvail pDecimal default (0)        
)        
      
CREATE  INDEX [IX_PdQtys_PdDate] ON [#PdQtys]([PdDate])       
        
      
--capture current on hand qty for non-serialized and serialized items        
        
Select @QtyOnHand = Sum(isnull(QtyOnHand, 0))        
 From dbo.tblDRRunItemLoc        
 Where RunId = @RunId and ItemId = @ItemId  and ((LocId = @LocId and @LocIdALL = 0) or        
(LocId in (Select LocId from dbo.tblDRRunItemLoc WHERE RunId = @RunId and ItemId = @ItemId) and @LocIdALL = 1))         
        
        
--Print '@QtyOnHand'        
--Print @QtyOnHand        
        
--ensure value isn't null        
Select @QtyOnHand = isnull(@QtyOnHand, 0)        
        
--capture item/loc defaults        
        
Select @QtySafetyStock = isnull(l.QtySafetyStock * p.ConvFactor, 0)        
 From dbo.tblInItemLoc l INNER JOIN dbo.tblInItemUom p ON l.ItemID = p.ItemId AND p.Uom = l.OrderQtyUom        
 Where l.ItemId = @ItemId And ((l.LocId = @LocId and @LocIdALL = 0) or         
(l.LocId in (Select Max(LocId) from dbo.tblInItemLoc  WHERE ItemId = @ItemId and QtySafetyStock <> 0) and @LocIdALL = 1))        
        
        
Select @QtySafetyStock  = isnull(@QtySafetyStock, 0)        
--Print '@QtySafetyStock'        
--Print @QtySafetyStock        
      
--build the period def date range          
      
Exec trav_DrQryPdDefBuildDateList @PdDefId, @StartDate          
      
        
--set date for prior/last and future periods        
Select @LateDate = dateadd(dd, -1, @StartDate)        
Select @FutureDate = max(Dateadd(dd, DaysInPd, IncDate)) From #DateList        
        
--add @LateDate/@FutureDate buckets at end of table so it's not included as a time fence period        
Insert into #DateList (IncDate, DaysInPd) Values (@LateDate, 1)        
Insert into #DateList (IncDate, DaysInPd) Values (@FutureDate, 1)        
        
--capture bucketed quantities        
      
        
Insert into #PdQtys(PdDate, SOCmtd, DrCmtd, BmCompReq, DrCompReq, BmOnOrder,WorkOder, PoOnOrder, PoPurReq, WMOnOrder, JcCmtd)        
Select cast(d.IncDate as DateTime)       
 , Round(Sum(Case When t.Source = 16 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 32 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 8 Then t.Qty when t.Source = 512 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 64 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 4 Then t.Qty  Else 0 End), @PrecQty)    
 , Round(Sum(Case When t.Source = 256 Then t.Qty Else 0 End), @PrecQty)  
 , Round(Sum(Case When t.Source = 1 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 2 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 1024 Then t.Qty Else 0 End), @PrecQty)        
 , Round(Sum(Case When t.Source = 2048 Then t.Qty Else 0 End), @PrecQty)        
 From #DateList d, (Select Case When convert(datetime, convert(varchar(10),  r.TransDate, 101)) < @StartDate Then @LateDate Else         
    Case When convert(datetime, convert(varchar(10),  r.TransDate, 101)) >= @FutureDate Then @FutureDate Else convert(datetime, convert(varchar(10),  r.TransDate, 101)) End End TransDate        
  , r.Source, Sum(r.Qty) Qty        
  From dbo.tblDRRunData r         
  Where r.RunId = @RunId and r.ItemId = @ItemId and ((r.LocId = @LocId AND @LocIdALL = 0) or @LocIdALL = 1)        
  Group By convert(datetime, convert(varchar(10),  r.TransDate, 101)), r.Source) t        
Where t.TransDate Between d.IncDate and dateadd(dd, d.DaysInPd - 1, d.IncDate)        
Group By d.IncDate        
      
        
If @ShowPriorYn <> 1         
Begin        
 --if not showing on report then remove from dataset        
 Delete #PdQtys Where PdDate < @StartDate          
 Delete #DateList Where IncDate < @StartDate        
      
End        
        
      
If @ShowFutureYn <> 1         
Begin        
 --if not showing on report then remove from dataset        
 Delete #PdQtys Where PdDate >= @FutureDate        
      
        
 Delete #DateList Where IncDate >= @FutureDate        
      
End        
        
--pack table to ensure records exist for each #DateList period        
      
        
Insert into #PdQtys(PdDate) Select IncDate From #DateList Where IncDate not in (Select PdDate From #PdQtys)        
        
      
      
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
           
        
        
        
Update #PdQtys Set #PdQtys.NetAvail = (@QtyOnHand - @QtySafetyStock) + isnull(tmp.NetAvail, 0)        
From (Select d.PdDate        
 , (Select Sum(PoOnOrder + BmOnOrder + PoPurReq + WmOnOrder + WorkOder        
  - Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)        
   Then  --larger of MS Comp Req vs Prod Ord Comp Req        
    Case When isnull(DrCompReq, 0) > isnull(BmCompReq , 0)        
     Then isnull(DrCompReq, 0)        
     Else isnull(BmCompReq, 0)        
     End        
   Else  --Act Prod Ord comp req        
    isnull(BmCompReq, 0)        
   End        
  - Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)        
   Then  --larger of frcst vs sales        
    Case When isnull(DrCmtd, 0) > (isnull(SoCmtd , 0) + isnull(JcCmtd, 0))        
     Then isnull(DrCmtd, 0)        
     Else (isnull(SoCmtd, 0) + isnull(JcCmtd, 0))        
     End        
   Else  --sales        
    (isnull(SoCmtd, 0) + isnull(JcCmtd, 0))        
   End        
  )        
  From #PdQtys q        
  Where q.PdDate <= d.PdDate) NetAvail         
 From #PdQtys d) tmp        
Where #PdQtys.PdDate = tmp.PdDate        
        
        
--update the On Hand quantity for each Period        
      
--adjust each active period        
Update #PdQtys Set #PdQtys.OnHand = isnull(tmp.OnHand, (@QtyOnHand - @QtySafetyStock))        
From (Select d.PdDate        
 , (Select Top 1 NetAvail From #PdQtys q        
  Where q.PdDate < d.PdDate        
  Order by q.PdDate Desc) OnHand        
 From #PdQtys d) tmp        
Where #PdQtys.PdDate = tmp.PdDate        
      
        
--return the resultset - convert to given UOM        
        
Select @ItemId ItemId, @LocId LocId, @TimeFencePds TimeFencePds, @FutureDate FutureDate, @StartDate StartDate        
 , Round(@QtySafetyStock / iu.ConvFactor, @PrecQty) QtySafetyStock        
 , q.PdDate, DateAdd(dd, d.DaysInPd - 1, q.PdDate) PdEndDate        
 , Round(OnHand / iu.ConvFactor, @PrecQty) OnHand        
 , Round(SoCmtd / iu.ConvFactor, @PrecQty) SoCmtd        
 , Round(DrCmtd / iu.ConvFactor, @PrecQty) DrCmtd        
 , Round(BmCompReq / iu.ConvFactor, @PrecQty) BmCompReq        
 , Round(DrCompReq / iu.ConvFactor, @PrecQty) DrCompReq        
 , Round(BmOnOrder / iu.ConvFactor, @PrecQty) BmOnOrder 
 , Round(WorkOder / iu.ConvFactor, @PrecQty) WorkOder        
 , Round(PoPurReq / iu.ConvFactor, @PrecQty) PoPurReq        
 , Round(PoOnOrder / iu.ConvFactor, @PrecQty) PoOnOrder        
 , Round(WmOnOrder / iu.ConvFactor, @PrecQty) WmOnOrder        
 , Round(JcCmtd / iu.ConvFactor, @PrecQty) JcCmtd        
 , Round(NetAvail / iu.ConvFactor, @PrecQty) NetAvail        
from #PdQtys q left join #DateList d        
 on q.PdDate = d.IncDate  Inner Join tblInItemUom iu on iu.ItemId=@ItemId and iu.Uom =@UOM        
Order by PdDate        
        
END TRY        
BEGIN CATCH        
      EXEC dbo.trav_RaiseError_proc        
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrRPView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrRPView_proc';


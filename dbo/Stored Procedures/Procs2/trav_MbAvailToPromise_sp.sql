  
CREATE PROCEDURE [dbo].[trav_MbAvailToPromise_sp]  
--PET:http://webfront:801/view.php?id=234233  
--PET:http://webfront:801/view.php?id=237090  
--PET:http://webfront:801/view.php?id=243302  
--PET:http://problemtrackingsystem.osas.com/view.php?id=263034  
--PET:http://problemtrackingsystem.osas.com/view.php?id=272474  
As  
  
SET NOCOUNT ON  
  
BEGIN TRY  
  
Declare @MaxDate datetime, @tmpDate datetime, @FirstAvailDate datetime, @AvailToPromDate datetime, @WksDate datetime  
Declare @ItemType smallint, @PrecQty smallint   
Declare  @QtyCmtd pDecimal,  @QtyOnOrder pDecimal, @QtyOnHand pDecimal, @LeadTime pDecimal, @ReqQty pDecimal  
  
  
  
  
  
 --Retrieve global values  
 --SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'  
 SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'  
 SELECT @LeadTime = Cast([Value] AS decimal) FROM #GlobalValues WHERE [Key] = 'LeadTime'  
 SELECT @ReqQty = Cast([Value] AS decimal) FROM #GlobalValues WHERE [Key] = 'ReqQty'  
 SELECT @QtyCmtd = Cast([Value] AS decimal) FROM #GlobalValues WHERE [Key] = 'QtyCmtd'  
 SELECT @QtyOnOrder = Cast([Value] AS decimal) FROM #GlobalValues WHERE [Key] = 'QtyOnOrder'  
 SELECT @QtyOnHand = Cast([Value] As decimal) FROM #GlobalValues WHERE [Key] = 'QtyOnHand'  
 SELECT @PrecQty = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecQty'  
 SELECT @ItemType = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'ItemType'  
  
   
 IF @WksDate IS NULL   
 BEGIN  
  RAISERROR(90025,16,1)  
 END  
  
--create quantity transaction table (Quantities in Base UOM)  
-- QtyAct - includes current OnHand + On Order - In Use quantities  
-- QtyEst - includes current OnHand + On Order - In Use - Committed quantities  
  
  
Create Table #TranQty  
(  
TranDate datetime,  
QtyAct pDecimal default(0),  
QtyEst pDecimal default(0)    
)  
  
--create quantity summary table (Quantities in Base UOM)  
Create Table #SumQty  
(  
TranDate datetime,  
QtyAct pDecimal default(0),  
QtyEst pDecimal default(0)  
)  
  
--get quantity for given item & location (use Cmtd, InUse and OnOrder as flags for skipping the processing of SO/PO)  
--Exec dbo.comQuantity @ItemID , @LocID , '', @ItemType, @QtyCmtd OUT, @QtyInUse OUT, @QtyOnOrder OUT, @QtyOnHand OUT  
  
--insert initial quantity on hand with todays date  
Insert into #TranQty(TranDate, QtyAct, QtyEst)   
Values (@WksDate, @QtyOnHand, @QtyOnHand)  
  
 --//this.ItemInfo.CurrentLocation.DfltLeadTime  
  
  
--insert a 0 quantity record for today + IN Lead time + 1 day to be used as the latest possible AvailDate  
Select @MaxDate = dateadd(d, @LeadTime + 1, @WksDate)  
Insert into #TranQty(TranDate, QtyAct, QtyEst)   
Values (@MaxDate, 0, 0)  
  
  
--Insert new/planned/firm planned/released (Status < 4) Orders (On Order Qtys)   
-- trans without live IN qtys - (between now and now + IN lead time)  
  
  
   
  
Insert into #TranQty (TranDate, QtyAct, QtyEst)  
 Select r.EstCompletionDate, Sum(0), Sum(Round(r.Qty * u.ConvFactor, @PrecQty))  
 From dbo.tblMpOrder o   
 Inner Join #ItemLocationList T on o.AssemblyId = T.ItemId and o.LocId = T.LocId  
 inner join dbo.tblMpOrderReleases r on o.OrderNo = r.OrderNo  
 Inner join (Select ItemId, UOM , Case When isnull(ConvFactor, 0) = 0 then 1 Else ConvFactor End ConvFactor   
   From dbo.tblInItemUOM) u  
 On o.AssemblyId = u.ItemId and r.Uom = u.UOM  
   
 Where r.Status < 4 and r.EstCompletionDate < @MaxDate  
  
 Group by r.EstCompletionDate  
  
  
--insert production orders (assemblies built/byproducts placed on order) (between now and now + IN lead time)  
If @QtyOnOrder <> 0   
Begin  
   
  
  
 Insert into #TranQty(TranDate, QtyAct, QtyEst)  
 Select r.EstStartDate, sum(q.Qty), Sum(q.Qty)  
  From dbo.tblinqty q   
     Inner Join #ItemLocationList T on q.itemid = T.ItemId and q.LocId = T.LocId  
  inner join dbo.tblMpMatlSum s on q.SeqNum = s.QtySeqNum  
  INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId  
  Where q.TransType = 2 and q.LinkId = 'MP' -- on order qty  
   
  Group by r.EstStartDate  
    
End  
  
  
--insert reversing committed material requisitions (between now and now + IN lead time)  
-- back out of estimated quantity  
If @QtyCmtd <> 0  
Begin  
  
  
   
   
 Insert into #TranQty(TranDate, QtyAct, QtyEst)  
 Select r.EstStartDate, -sum(q.Qty), -sum(q.Qty)   
  From dbo.tblinqty q  
  Inner Join #ItemLocationList T on q.itemid = T.ItemId and q.LocId = T.LocId   
  inner join dbo.tblMpMatlSum s on q.SeqNum = s.QtySeqNum  
  INNER JOIN dbo.tblMpRequirements r ON s.TransId = r.TransId  
  Where q.TransType = 0 and q.LinkId = 'MP' -- committed qty  
   
  and r.EstStartDate < @MaxDate  
  Group by r.EstStartDate  
    
End  
  
----insert reversing in use material requisitions (between now and now + IN lead time)  
--If @QtyInUse <> 0  
--Begin  
  
-- Insert into #TranQty(TranDate, QtyAct, QtyEst)  
-- Select s.RequiredDate, -sum(q.Qty), -Sum(q.Qty)  
--  From dbo.tblinqty q   
--  Inner Join #ItemLocationList T on q.itemid = T.ItemId and q.LocId = T.LocId   
--  inner join dbo.tblMpMatlDtl d on q.SeqNum = d.QtySeqNum  
--  inner join dbo.tblMpMatlSum s    
--  on d.TransId = s.TransId  
--  Where q.TransType = 1 and q.LinkId = 'MP' -- in use qty  
--  --And q.itemid = @ItemId and q.LocId = @LocId   
--  and s.RequiredDate < @MaxDate  
--  Group by s.RequiredDate  
--End  
  
--insert reversing committed quantities for SO transactions (between now and now + IN lead time)  
-- back out of estimated quantity  
If @QtyCmtd <> 0  
Begin  
  
  
 Insert into #TranQty(TranDate,  QtyAct, QtyEst)  
 Select Coalesce(tmp.ReqShipDate, h.ReqShipDate), -sum(q.Qty), -sum(q.Qty)   
  From dbo.tblinqty q   
    
  Inner Join #ItemLocationList T on q.itemid = T.ItemId and q.LocId = T.LocId   
  inner join (Select d.TransId, d.ReqShipDate, isnull(e.QtySeqNum_Cmtd, d.QtySeqNum_Cmtd) QtySeqNum_Cmtd  
   From dbo.tblSoTransDetail d Left Join dbo.tblSoTransDetailExt e  
   on d.TransId = e.TransId and d.EntryNum = e.EntryNum WHERE d.Status = 0) tmp  
  on q.SeqNum = tmp.QtySeqNum_Cmtd  
  inner join dbo.tblSoTransHeader h on tmp.TransId = h.TransId  
  Where q.TransType = 0 and q.LinkId = 'SO' -- committed qty  
   
  and Coalesce(tmp.ReqShipDate, h.ReqShipDate) < @MaxDate  
  Group by Coalesce(tmp.ReqShipDate, h.ReqShipDate)  
  
End  
  
  
  
--insert pending onorder quantities for PO trans (between now and now + IN lead time)  
If @QtyOnOrder <> 0  
Begin  
   
  
 Insert into #TranQty(TranDate, QtyAct, QtyEst)  
 Select ISNULL(d.ExpReceiptDate,h.ExpReceiptDate), sum(q.Qty), Sum(q.Qty)  
   From dbo.tblinqty q   
  Inner Join #ItemLocationList T on q.itemid = T.ItemId and q.LocId = T.LocId   
  inner join dbo.tblPoTransDetail d on q.SeqNum = d.QtySeqNum  
  inner join dbo.tblPoTransHeader h on d.TransId = h.TransId  
  Where q.TransType = 2 and q.LinkId = 'PO'   
  --And q.itemid = @ItemId and q.LocId = @LocId   
  and ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) < @MaxDate  
  Group by ISNULL(d.ExpReceiptDate,h.ExpReceiptDate)   
   
End  
  
--populate the summary quantity table from the quantity transactions  
insert into #SumQty(TranDate, QtyAct, QtyEst)   
 Select TranDate, Sum(QtyAct), Sum(QtyEst) From #TranQty Group By TranDate  
  
--FirstDate (the first date the requested qty would be available if all other orders (committed qtys) were ignored)  
--find min date where sum of QtyAct => required qty (if not found use max date - now+leadtime+1)  
Select @tmpDate = min(s1.TranDate) From #SumQty s1   
 Where (Select Sum(s2.QtyAct) From #SumQty s2   
  Where s2.TranDate <= s1.TranDate) >= @ReqQty  
Select @FirstAvailDate = Coalesce(@tmpDate, @MaxDate)  
If @FirstAvailDate < @WksDate Select @FirstAvailDate = @WksDate  
  
--AvailDate (the first date the requested qty would be available if all other orders (committed qtys) are considered)  
-- find max date where sum of QtyEst - required qty < 0   
Select @tmpDate = max(s1.TranDate) From #SumQty s1  
 Where (Select Sum(s2.QtyEst) From #SumQty s2  
  Where s2.TranDate <= s1.TranDate) < @ReqQty  
    
If @tmpDate is null  
Begin  
 --if not found then use FirstDate   
 Select @AvailToPromDate = @FirstAvailDate  
End  
Else  
Begin  
 --otherwise find the min date > the max neg qty date where the sum of quantities - required qty => 0  
 Select @tmpDate = min(s1.TranDate) From #SumQty s1  
  Where s1.TranDate > @tmpDate   
  and (Select Sum(s2.QtyEst) From #SumQty s2  
   Where s2.TranDate <= s1.TranDate) >= @ReqQty  
 --if not found then use today + IN Lead time + 1 day  
 Select @AvailToPromDate = Coalesce(@tmpDate, @MaxDate)  
 If @AvailToPromDate < @WksDate Select @AvailToPromDate = @WksDate  
End  
  
if @ReqQty <= @QtyOnHand   
begin  
 set @FirstAvailDate = @WksDate  
end  
  
insert Into  #ItemAvailableToPromise (ItemId, LocId, ReqQty, QtyOnHand, AvailToPromDate, FirstAvailDate)  
Select  T.ItemId,  T.LocId , @ReqQty, @QtyOnHand, @AvailToPromDate, @FirstAvailDate   
from #ItemLocationList T      
  
                                
END TRY  
BEGIN CATCH  
      EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbAvailToPromise_sp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbAvailToPromise_sp';


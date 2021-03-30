
Create procedure dbo.trav_DrComponentPeggingView_proc      
@AssemblyId pItemId,      
@LocId pLocId,      
@UOM pUOM,      
@PdDefId nvarchar(10),      
@WksDate Datetime=null,      
@PrecQty tinyint = 4,  
@ShowPriorYn bit = 1    
      
      
As      
     
set nocount on      
BEGIN TRY    
--1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256=WorkOrds / 512=WorkOrdComp / 1024=WM Transfer / 2048=JC Estimates      
      
Declare @RetVal int      
Declare @LastDate datetime      
Declare @TimeFencePds smallint      
Declare @TimeFenceDate datetime      
Declare @ConvFactor pDecimal      
 declare @convdate nvarchar(10)    
--Declare @Done bit    
    
If isnull(@WksDate,'')=''     
Begin    
 Set @convdate=convert(nvarchar(10),GETDATE(),101)    
 Set @WksDate =CONVERT(smalldatetime,@convdate,101)    
     
End    
--Period def date list       
Create table #DateList(PdId int identity(1, 1), IncDate datetime, DaysInPd int)      
      
--period qty buckets    
-- Mod: added components requirement columns    
Create table #PdQtys      
(      
PdDate datetime Null,       
SoCmtd pDecimal default(0),       
DrCmtd pDecimal default(0),       
JcCmtd pDecimal default(0),  
MsCompReq pDecimal default(0),   
MpCompReq pDecimal default(0),       
FrcstAppYn bit default (0),   
MsCompAppYn   bit default (0)  
)      
      
    
--build the period def date range starting with todays date      
Exec dbo.trav_DrQryPdDefBuildDateList @PdDefId, @WksDate      
      
     
--capture bucketed quantities (to determine which is applicable = act sales vs frcst)      
     
Insert into #PdQtys(PdDate, SoCmtd, DrCmtd, JcCmtd,MsCompReq,MpCompReq)      
Select Case When t.TransDate < @WksDate Then Null Else d.IncDate End      
 , Round(Sum(Case When t.Source = 16 Then t.Qty Else 0 End), @PrecQty)      
 , Round(Sum(Case When t.Source = 32 Then t.Qty Else 0 End), @PrecQty)      
 , Round(Sum(Case When t.Source = 2048 Then t.Qty Else 0 End), @PrecQty)  
 , Round(Sum(Case When t.Source = 64 Then t.Qty Else 0 End), @PrecQty)   
 , Round(Sum(Case When t.Source = 8 Then t.Qty when t.Source = 512 Then t.Qty Else 0 End), @PrecQty)     
 From #DateList d, (Select TransDate, Source, Qty       
   From dbo.tblDRRunData      
   Where ItemId = @AssemblyId and LocId = @LocId) t      
Where t.TransDate Between d.IncDate and dateadd(dd, d.DaysInPd - 1, d.IncDate)      
Group By Case When t.TransDate < @WksDate Then Null Else d.IncDate End      
      
  
      
--must find the respective date for the given time fence periods       
-- to determine usage of actual vs forecasted quantity values      
Select @TimeFencePds = TimeFencePds      
 From dbo.tblDrPeriodDef      
 Where PdDefId = @PdDefId      
      
Set @TimeFenceDate = Null      
      
Select @TimeFenceDate = Max(IncDate)      
 From #DateList      
 Where PdId <= @TimeFencePds              
      
Update #PdQtys Set #PdQtys.FrcstAppYn = tmp.FrcstAppYn, #PdQtys.MsCompAppYn=  tmp.MsCompAppYn  
From (Select d.PdDate      
 , Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)      
  Then  --larger of frcst vs sales       
   Case When isnull(DrCmtd, 0) > (isnull(SoCmtd , 0) + isnull(JcCmtd , 0))      
    Then 1      
    Else 0      
    End      
  Else  --sales      
   0      
  End FrcstAppYn,  
  Case When (isnull(@TimeFencePds, 0) = 0) or (@TimeFenceDate is null) or (PdDate > @TimeFenceDate)      
  Then  --larger of MScomp vs Comp req      
   Case When isnull(MsCompReq, 0) >  isnull(MpCompReq , 0)      
    Then 1      
    Else 0      
    End      
  Else  --Comp Req     
   0      
  End MsCompAppYn      
 From #PdQtys d) tmp      
Where #PdQtys.PdDate = tmp.PdDate      
    
   
      
    
--return the resultset - convert to given UOM      
SELECT @ConvFactor = ConvFactor      
FROM dbo.tblInItemUom      
WHERE ItemID = @AssemblyId and Uom = @Uom     
     
--Exec dbo.comUnitConversion @AssemblyId, @UOM, @ConvFactor out, null, null      
Select @ConvFactor = Case When isnull(@ConvFactor, 0) = 0 Then 1 Else @ConvFactor End      
 --1=PurchOrds / 2=PurchReqs / 16=SalesOrds / 32=FrcstSales / 64=MstrSchedComp / 128=MstrSchedProduction / 256=WorkOrds / 512=WorkOrdComp / 1024=WM Transfer / 2048=JC Estimates      
Select  t.TransDate  MRPDate     
 , t.SeqNum, t.ItemId, t.LocId, t.TransDate DocDate, t.TransType    
 , t.Source, t.VirtualYn      
 , Cast(Round(t.Qty / @ConvFactor, @PrecQty) as float) Quantity      
 , t.LinkId , t.LinkIDSub DocID, t.LinkIdSubLine Reference, t.CustId, t.VendorId      
 , Cast(case when @ShowPriorYn=1 then  
   Case   
    When t.Source = 16 or t.Source = 32 or t.Source = 2048 Then    
      
            
       Case When t.Source = 32 Then 0 Else 1 End      
        
    When t.Source = 8 or t.Source = 512 or t.Source =64  Then    
         
      Case When t.Source = 64 Then 0 Else 1 End      
         
     Else 1   
    End  
    Else 0  
    End as bit ) Applicable      
 From (Select * From dbo.tblDRRunData      
   Where ItemId = @AssemblyId and LocId = @LocId) t  where t.TransDate < @WksDate    
          
  
UNION  
     
Select Case When t.TransDate < @WksDate Then @LastDate Else d.IncDate End MRPDate     
 , t.SeqNum, t.ItemId, t.LocId, t.TransDate DocDate, t.TransType    
 , t.Source, t.VirtualYn      
 , Cast(Round(t.Qty / @ConvFactor, @PrecQty) as float) Quantity      
 , t.LinkId , t.LinkIDSub DocID, t.LinkIdSubLine Reference, t.CustId, t.VendorId      
 , Cast(Case   
   When t.Source = 16 or t.Source = 32 or t.Source = 2048 Then    
     
      Case When isnull((Select FrcstAppYn From #PdQtys Where PdDate = Case When t.TransDate < @WksDate Then @LastDate Else d.IncDate End), 0) = 1       
      Then Case When t.Source = 32 Then 1 Else 0 End      
      Else Case When (t.Source = 16) or (t.Source = 2048) Then 1 Else 0 End      
      End   
   When t.Source = 8 or t.Source = 512 or t.Source =64  Then    
      Case When isnull((Select MsCompAppYn From #PdQtys Where PdDate = Case When t.TransDate < @WksDate Then @LastDate Else d.IncDate End), 0) = 1       
      Then Case When t.Source = 64 Then 1 Else 0 End      
      Else Case When (t.Source = 8) or (t.Source = 512) Then 1 Else 0 End      
      End   
    Else 1   
    End as bit ) Applicable      
 From #DateList d, (Select * From dbo.tblDRRunData      
   Where ItemId = @AssemblyId and LocId = @LocId) t      
Where t.TransDate Between d.IncDate and dateadd(dd, d.DaysInPd - 1, d.IncDate)      
Order By TransDate      
  
    
     
END TRY    
BEGIN CATCH    
EXEC dbo.trav_RaiseError_proc    
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrComponentPeggingView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrComponentPeggingView_proc';


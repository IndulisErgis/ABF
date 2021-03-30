
CREATE PROCEDURE dbo.trav_PaCheckPost_UpdateEmpHist_proc
AS
BEGIN TRY
        DECLARE @PostRun pPostRun, @PdEnd datetime, @iMonth tinyint, @DateOnCheck datetime, @WksDate datetime,
       
        @PaYear smallint,@UnemploymentTax smallint,  
        @DfltCheckNum nvarchar(10), 

		@cAllocatedTips nvarchar(30),@cUncollectedOASDI nvarchar(30),
		@cUncollectedMedicare nvarchar(30),@cFICATips nvarchar(30),
		@cAdvEICPayment nvarchar(30), @cHoursWorked nvarchar(30),
		@cWeeksWorked nvarchar(30),@cWeeksUnderLimit nvarchar(30),
    
        @cPaidMonth nvarchar(30)

    
        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	    SELECT @iMonth = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'iMonth'
        SELECT @PdEnd = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PdEnd'
        SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
		SELECT @PaYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PaYear'
		SELECT @UnemploymentTax = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'UnemploymentTax'
        SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'
        SELECT @DfltCheckNum = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'DfltCheckNum'
      
        

		--SELECT @cAllocatedTips  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Allocated Tips'
		--SELECT @cUncollectedOASDI  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Uncollected OASDI'
		--SELECT @cUncollectedMedicare  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Uncollected Medicare'
		--SELECT @cFICATips  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'FICA Tips'
		--SELECT @cAdvEICPayment  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Adv EIC Payment'
		--SELECT @cHoursWorked  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Hours Worked'
		--SELECT @cWeeksWorked  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Weeks Worked'
		--SELECT @cWeeksUnderLimit  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Weeks Under Limit'
        --SELECT @cPaidMonth  = Cast([Descr] AS nvarchar(30)) FROM dbo.tblPaMiscCode WHERE [Descr] =  'Paid/Month'



UPDATE dbo.tblPaCheck SET CheckNumber = @DfltCheckNum WHERE CheckNumber IS NULL





INSERT INTO dbo.tblPaEmpHistEarn 
(EntryDate, PaYear, EmployeeId, EarningCode, PaMonth, Hours, Amount, CF)   

SELECT @DateOnCheck, c.PaYear, c.EmployeeId, e.EarningCode, @iMonth,
   e.HoursWorked, e.EarningAmount, e.CF
FROM dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId
INNER JOIN
    dbo.tblPaCheckEarn e ON 
    c.Id = e.CheckId



INSERT INTO dbo.tblPaEmpHistDeduct 
		(EntryDate, PaYear, EmployeeId, PaMonth,  DeductionCode, EmployerPaid, Amount, CF)   
SELECT @DateOnCheck, c.PaYear, c.EmployeeId, @iMonth, e.DeductionCode, 0, e.DeductionAmount, c.CF
FROM dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId
INNER JOIN
    dbo.tblPaCheckDeduct e ON 
    c.Id = e.CheckId


INSERT INTO dbo.tblPaEmpHistDeduct 
		(EntryDate, PaYear, EmployeeId, PaMonth, DeductionCode, EmployerPaid, Amount, CF)   
SELECT @DateOnCheck, c.PaYear, c.EmployeeId, @iMonth, e.DeductionCode, 1, e.DeductionAmount, e.CF
FROM dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId
INNER JOIN
    dbo.tblPaCheckEmplrCost e ON 
    c.Id = e.CheckId



INSERT INTO dbo.tblPaEmpHistWithhold 
(EntryDate, PaYear, PaMonth, EmployeeId, TaxAuthorityType, [State], [Local], 
WithholdingCode, EmployerPaid, EarningAmount, TaxableAmount, WithholdAmount, CF )                                                                                                                                                                                                                                                         
Select @DateOnCheck, c.PaYear, @iMonth, c.EmployeeId, tax.[Type], tax.[State], tax.[Local],  
 e.WithholdingCode, d.EmployerPaid, e.GrossEarnings, e.WithholdingEarnings, e.WithholdingPayments, e.CF      
  FROM dbo.tblPaCheck c 
Inner Join #PostTransList b ON c.Id = b.TransId
  INNER JOIN
    dbo.tblPaCheckWithhold e ON 
    c.Id = e.CheckId Inner Join dbo.tblPaTaxAuthorityHeader tax on tax.Id = e.TaxAuthorityId
Inner Join dbo.tblPaTaxAuthorityDetail d on e.TaxAuthorityDtlId = d.Id
WHERE  d.EmployerPaid = 0 



INSERT INTO dbo.tblPaEmpHistWithhold 
(EntryDate, PaYear, PaMonth, EmployeeId, TaxAuthorityType, [State], [Local], 
WithholdingCode, EmployerPaid, EarningAmount, TaxableAmount, WithholdAmount, CF )                                                                                                                                                                                                                                                         

Select @DateOnCheck, c.PaYear, @iMonth, c.EmployeeId, tax.[Type], tax.[State], tax.[Local],  
 e.WithholdingCode, d.EmployerPaid, e.GrossEarnings, e.WithholdingEarnings, e.WithholdingPayments, e.CF      
  FROM dbo.tblPaCheck c 
Inner Join #PostTransList b ON c.Id = b.TransId
  INNER JOIN
     dbo.tblPaCheckEmplrTax e ON 
    c.Id = e.CheckId Inner Join dbo.tblPaTaxAuthorityHeader tax on tax.Id = e.TaxAuthorityId
Inner Join dbo.tblPaTaxAuthorityDetail d on e.TaxAuthorityDtlId = d.Id
WHERE  d.EmployerPaid = 1 



Insert Into tblPa941ScheduleB(
		PaYear, PaMonth, PaDay, Amount, CF)

Select c.PaYear, Month(@DateOnCheck),  cast(Day(@DateOnCheck) as nvarchar(2)), e.WithholdingPayments,e.CF         
  FROM dbo.tblPaCheck c 
Inner Join #PostTransList b ON c.Id = b.TransId
  INNER JOIN
    dbo.tblPaCheckEmplrTax e ON 
    c.Id = e.CheckId Inner Join dbo.tblPaTaxAuthorityHeader tax on tax.Id = e.TaxAuthorityId
Inner Join dbo.tblPaTaxAuthorityDetail d on e.TaxAuthorityDtlId = d.Id
WHERE  d.EmployerPaid = 1 and tax.[Type] = 0 and e.WithholdingCode <> 'FUT' AND d.CodeType <> @UnemploymentTax

Insert Into tblPa941ScheduleB(
		PaYear, PaMonth, PaDay, Amount, CF)
Select c.PaYear, Month(@DateOnCheck),  cast(Day(@DateOnCheck) as nvarchar(2)), e.WithholdingPayments,e.CF         
  FROM dbo.tblPaCheck c 
Inner Join #PostTransList b ON c.Id = b.TransId
  INNER JOIN
    dbo.tblPaCheckWithhold e ON 
    c.Id = e.CheckId Inner Join dbo.tblPaTaxAuthorityHeader tax on tax.Id = e.TaxAuthorityId
Inner Join dbo.tblPaTaxAuthorityDetail d on e.TaxAuthorityDtlId = d.Id
WHERE  d.EmployerPaid = 0 and tax.[Type] = 0 


 --HoursWorked

INSERT INTO dbo.tblPaEmpHistLeave(
EntryDate, PaYear, PaMonth, EmployeeId,  LeaveCodeId, PrintedFlag, [From], EarningCode, [Description],
CheckNumber, AdjustmentDate, AdjustmentAmount, CF)  

SELECT  @DateOnCheck, c.PaYear, @iMonth, c.EmployeeId, e.LeaveCodeId, 0, 'PC', e.EarningCode,'Post Checks', 
	c.CheckNumber, @DateOnCheck, -HoursWorked, e.CF
FROM dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId
INNER JOIN dbo.tblPaCheckEarn e ON c.Id = e.CheckId
WHERE NULLIF(e.LeaveCodeId, '') Is Not NULL

 --accrued


INSERT INTO dbo.tblPaEmpHistLeave(
EntryDate, PaYear, PaMonth, EmployeeId,  LeaveCodeId, PrintedFlag, [From], [Description],
CheckNumber, AdjustmentDate, AdjustmentAmount, CF)  
SELECT @DateOnCheck, c.PaYear, @iMonth, c.EmployeeId, l.LeaveCodeId, 0, 'PC', 'Post Checks', 
	c.CheckNumber, @DateOnCheck, l.HoursAccrued, l.CF
FROM dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId
 INNER JOIN dbo.tblPaCheckLeave l ON  c.Id = l.CheckId
WHERE l.HoursAccrued <> 0



--Offsets the amount  UNCOLOASDI and UNCOLMED

INSERT INTO dbo.tblPaEmpHistMisc
(EntryDate, PaYear, PaMonth, EmployeeId, MiscCodeId, Amount, CF)
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId,
13 as Id,  (c.UncollectedOasdi - c.CollOnUncolOasdi) - coalesce(a.Amount, 0), c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId 
Left JOIN
(
Select m.EmployeeId, c.Id, sum(m.Amount) Amount from dbo.tblPaEmpHistMisc  m
Inner Join dbo.tblPaCheck c on m.EmployeeId = c.EmployeeId
Inner Join #PostTransList b ON c.Id = b.TransId 
WHERE m.MiscCodeId = 13 and m.PaYear = @PaYear  
group by  m.EmployeeId, c.Id having sum(m.Amount) > 0)a on a.Id = c.Id 


--Offsets the amount  UncollectedMedicare CollOnUncolMed

INSERT INTO dbo.tblPaEmpHistMisc
(EntryDate, PaYear, PaMonth, EmployeeId, MiscCodeId, Amount, CF)
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId,
14 as Id, (c.UncollectedMedicare - c.CollOnUncolMed) - coalesce(a.Amount, 0), c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId 
Left Join 
(
Select m.EmployeeId, c.Id, sum(m.Amount) Amount from dbo.tblPaEmpHistMisc  m
Inner Join dbo.tblPaCheck c on m.EmployeeId = c.EmployeeId
Inner Join #PostTransList b ON c.Id = b.TransId 
WHERE m.MiscCodeId = 14 and m.PaYear = @PaYear
group by  m.EmployeeId, c.Id having sum(m.Amount) > 0)a on a.Id = c.Id 




INSERT INTO dbo.tblPaEmpHistMisc
(EntryDate, PaYear, PaMonth, EmployeeId, MiscCodeId, Amount, CF)
Select  v.CheckDate, v.PaYear, v.PaMonth, v.EmployeeId, v.Id, v.Amount, v.CF
from
(
Select isnull(c.CheckDate, @DateOnCheck) as CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId, 
1 as Id, c.TotalHoursWorked as Amount, c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId ----@cHoursWorked
union all
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId, 
2 as Id, c.WeeksWorked as Amount, c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId ---@cWeeksWorked
union all
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId, 
3 as Id, c.WeeksUnderLimit as Amount, c.CF
from dbo.tblPaCheck c  Inner Join #PostTransList b ON c.Id = b.TransId ---@cWeeksUnderLimit
union all
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId, 
11 as Id, c.FicaTips as Amount, c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId --@cFICATips
union all
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth,c.EmployeeId, 
15 as Id, c.TipsDeemedWages as Amount, c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId --TipsDeemedWages

) v
WHERE v.Id is not Null and v.Amount <> 0



--Paid/Month

INSERT INTO dbo.tblPaEmpHistMisc
(EntryDate, PaYear, PaMonth, EmployeeId, MiscCodeId, Amount, CF)
Select isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth as PaMonth, c.EmployeeId,  
4  as Id, 1 as Amount, c.CF
from dbo.tblPaCheck c Inner Join #PostTransList b ON c.Id = b.TransId ---@cPaidMonth 
WHERE c.GrossPay + c.NetPay <> 0 and c.EmployeeId not in
(Select EmployeeId from dbo.tblPaEmpHistMisc WHERE PaYear = @PaYear and PaMonth = @iMonth
and MiscCodeId = 4)


INSERT INTO dbo.tblPaEmpHistMisc
(EntryDate, PaYear, PaMonth, EmployeeId, MiscCodeId, Amount, CF)
Select  v.CheckDate, v.PaYear, v.PaMonth, v.EmployeeId, v.Id, v.Amount, v.CF 
from 

(Select  Isnull(c.CheckDate, @DateOnCheck) CheckDate, c.PaYear, @iMonth PaMonth, c.EmployeeId,
12 as Id, 
e.WithholdingPayments as Amount, c.CF     
  FROM dbo.tblPaCheck c 
Inner Join #PostTransList b ON c.Id = b.TransId ---@cAdvEICPayment
  INNER JOIN
    dbo.tblPaCheckWithhold e ON 
    c.Id = e.CheckId Inner Join dbo.tblPaTaxAuthorityHeader tax on tax.Id = e.TaxAuthorityId
Inner Join dbo.tblPaTaxAuthorityDetail d on e.TaxAuthorityDtlId = d.Id
WHERE  tax.[Type] = 0 and e.WithholdingCode = 'EIC') v WHERE v.Id is not null  


Insert Into  dbo.tblPaEmpHistGrossNet(
		EntryDate,PaYear,PaMonth,EmployeeId,GrossPayAmount,NetPayAmount,CF)    
Select Isnull(c.CheckDate,@DateOnCheck), c.PaYear, @iMonth, c.EmployeeId, c.GrossPay, c.NetPay, c.CF
from dbo.tblPaCheck c
Inner Join #PostTransList b ON c.Id = b.TransId
 


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateEmpHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateEmpHist_proc';



CREATE PROCEDURE dbo.trav_PaCheckPost_UpdateCheckHist_proc
AS
BEGIN TRY

--PET:http://webfront:801/view.php?id=226809
--PET:http://webfront:801/view.php?id=226572
--PET:http://webfront:801/view.php?id=226335
--PET:http://webfront:801/view.php?id=226466
--PET:http://webfront:801/view.php?id=226840
--PET:http://webfront:801/view.php?id=227049
--PET:http://webfront:801/view.php?id=227125
--PET:http://webfront:801/view.php?id=227220
--PET:http://webfront:801/view.php?id=227561
--PET:http://webfront:801/view.php?id=228525
--PET:http://webfront:801/view.php?id=241925
--PET:http://webfront:801/view.php?id=245493

    DECLARE @PostRun pPostRun, @PdEnd datetime, @iMonth tinyint, @DateOnCheck datetime, 
        @BankID nvarchar(10), @WksDate datetime,  @Earnings smallint,
        @GlPeriod tinyint,  @PostYear smallint, @GlCashAcct nvarchar(40), 
        @Deductions smallint, @AdvPmtAcct nvarchar(40)

        SELECT @Earnings = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Earnings'
        SELECT @Deductions = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'Deductions'
        SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	    SELECT @iMonth = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'iMonth'
        SELECT @PdEnd = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'PdEnd'
        
        SELECT @DateOnCheck = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'DateOnCheck'
        SELECT @BankID = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'BankID'
		
		SELECT @PostYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PostYear'
        SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WksDate'
        SELECT @GlPeriod = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'GlPeriod'
        SELECT @GlCashAcct = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'GlCashAcct'
		SELECT @AdvPmtAcct = Cast([Value] AS nvarchar(40)) FROM #GlobalValues WHERE [Key] = 'AdvPmtAcct'

   

   IF @PostRun IS NULL  OR @PdEnd IS NULL OR @DateOnCheck IS NULL OR @iMonth IS NULL OR @BankID IS NULL Or
	@PostYear IS NULL or @WksDate IS NULL 


	BEGIN
		RAISERROR(90025,16,1)
	END
   

--MOD: Join dbo.tblPaCheckInfoGroup with the  dbo.tblPaCheckInfo


INSERT INTO dbo.tblPaCheckHist 
(PostRun, Id, EmployeeId, EmployeeType,
 EmployeeName, DepartmentId, SocialSecurityNo, CheckNumber, GroupCode,
 GrossPay, NetPay, [Type], WeeksWorked, HoursWorked, WeeksUnderLimit,
 FicaTips, TipsDeemedWages, 
 UncollectedOasdi, UncollectedMedicare, CollOnUncollOasdi, CollOnUncollMed,
 CheckDate, PaMonth, BankId, CheckRun, PaYear, GlYear, GLPeriod, PeriodRunCode, VoucherNumber, 
Voided, SelectedYn, TipsReported, GLAcctCash, CF)
SELECT @PostRun, C.Id, C.EmployeeId, e.EmployeeType, 
Left( COALESCE (s.LastName, '') + ', ' + COALESCE (s.FirstName, '') 
    + ' ' + COALESCE (s.MiddleInit, ''), 36) EmplName,
 e.DepartmentId, s.SocialSecurityNo, C.CheckNumber, 
 e.GroupCode, C.GrossPay, COALESCE(c.NetPay, 0) NetPay, C.Type,
 C.WeeksWorked, C.TotalHoursWorked,
 C.WeeksUnderLimit, C.FicaTips,
 C.TipsDeemedWages, 
 C.UncollectedOasdi, C.UncollectedMedicare,
 C.CollOnUncolOasdi, C.CollOnUncolMed,
 @DateOnCheck, @iMonth, @BankId,
 @WksDate, C.PaYear, @PostYear,
 @GlPeriod, C.PdCode, C.VoucherNumber,
--Case When Isnull(C.VoidHistCheckId, '') = '' then 0 else 1 end  as Voided, 
0 as Voided,
0, 0, @GlCashAcct, C.CF
FROM (dbo.tblPaCheck C INNER JOIN #PostTransList b ON C.Id = b.TransId
INNER JOIN   
( dbo.tblSmEmployee s inner Join dbo.tblPaEmployee e on  s.EmployeeId = e.EmployeeId)
ON C.EmployeeId = e.EmployeeId 
)
-- INNER JOIN dbo.tblPaCheckInfoGroup AS G ON e.GroupCode = G.Id INNER JOin dbo.tblPaCheckInfo f on 
--f.Id = G.InfoID and f.PaYear = @PaYear

 
 INSERT INTO dbo.tblPaCheckHistEarn (PostRun, CheckId, Id,
 EarningCode,TaxGroup, StateCode, SUIState, LocalCode, DepartmentId, LaborClass, HoursWorked,
 HourlyRate, EarningsAmount, Pieces, CustID, ProjID, PhaseID, TaskID, DeptAllocId, LeaveCodeId, CF)
SELECT @PostRun,  c.CheckId,  c.Id,  c.EarningCode,g.TaxGroup,
  t.[State],  c.SUIState, l.[TaxAuthority], c.DepartmentId,  c.LaborClass,  c.HoursWorked,
  c.EarningCodeRate,  c.EarningAmount,  c.Pieces,  c.CustID,  c.ProjID,  c.PhaseID,  
c.TaskID,  c.DeptAllocId,  c.LeaveCodeId,c.CF
FROM dbo.tblPaCheckEarn c INNER JOIN #PostTransList b ON c.CheckId = b.TransId
LEFT JOIN dbo.tblPaTaxAuthorityHeader t  on c.StateTaxAuthorityId = t.Id 
AND t.[State] IS NOT NULL 
LEFT JOIN dbo.tblPaTaxAuthorityHeader l on c.LocalTaxAuthorityId = l.Id
AND  l.[Local] IS NOT NULL 
LEFT JOIN dbo.tblPaTaxGroupHeader g ON c.TaxGroupId = g.ID


--Update Check Deductions History File (tblPaCheckHistDeduct)

INSERT INTO dbo.tblPaCheckHistDeduct (PostRun, CheckId, Id,
 DeductionCode, Amount, Hours, GLAcctLiability, CF)
 SELECT @PostRun, d.CheckId, d.Id,
 d.DeductionCode, d.DeductionAmount, d.DeductionHours, e.GLLiabilityAccount, d.CF
FROM dbo.tblPaCheckDeduct d
Inner join dbo.tblPaDeductCode e on e.DeductionCode = d.DeductionCode
Inner Join #PostTransList b ON d.CheckId = b.TransId and  e.EmployerPaid = 0


--Check Hist Leave
	INSERT INTO dbo.tblPaCheckHistLeave ([PostRun],[Id], [CheckId], [LeaveCodeId], [HoursAccrued])	
	SELECT @PostRun, cl.[Id], cl.CheckId, cl.[LeaveCodeId], cl.[HoursAccrued]
    from dbo.tblPaCheck c 
    INNER JOIN dbo.tblPaCheckLeave cl ON  c.Id = cl.CheckId
    inner Join #PostTransList l ON l.TransId = c.Id


--Update Check Employer Costs History File (tblPaCheckHistEmplrCost)

CREATE TABLE #tmpCost (
	[CheckId] [int], 
	[Id] [int] IDENTITY (1, 1) NOT NULL ,
	[DeductionCode] [pCode] NULL ,
	[DepartmentId] [pDeptID] NULL , 
	[Amount] [pDecimal] NULL, 
	[Hours] [pDecimal] NULL, 
	[CF] [xml] NULL
	)


INSERT INTO #tmpCost ( CheckId,
DeductionCode, DepartmentId, Amount, Hours,CF)
SELECT 
t.CheckId, t.DeductionCode, l.DepartmentId, l.AllocCost, 
t.DeductionHours,t.CF
FROM dbo.tblPaCheckEmplrCost  t 
inner join  #tmpPaAllocCost l 
on t.CheckId = l.CheckId and t.DeductionCode = l.DeductionCode
WHERE (l.AllocCost + t.DeductionHours) <> 0


INSERT INTO dbo.tblPaCheckHistEmplrCost (PostRun, CheckId, Id,
DeductionCode, DepartmentId, Amount, Hours, GLAcctLiability, GLAcctDept,CF)
SELECT @PostRun, 
t.CheckId, t.Id,
t.DeductionCode, t.DepartmentId, t.Amount, t.Hours,  e.GLLiabilityAccount, dd.GLAcct, t.CF
FROM #tmpCost  t 
Inner join dbo.tblPaDeductCode e on e.DeductionCode = t.DeductionCode
Inner Join dbo.tblPaDeptDtl dd  ON dd.DepartmentId = t.DepartmentId and dd.code = t.DeductionCode
and dd.Type = @Deductions and  e.EmployerPaid = 1


--insert Check Withholdings History File (tblPaCheckHistWithhold)


INSERT INTO dbo.tblPaCheckHistWithhold (PostRun, CheckId, Id,
TaxAuthorityType, [State], [Local], WithholdingCode,Description, WithholdingEarnings, 
WithholdingAmount, GrossEarnings, GLAcctLiability,CF)

SELECT @PostRun, w.CheckId, w.Id, h.[Type], h.[State], h.[Local],
 w.WithholdingCode, w.Description, w.WithholdingEarnings, w.WithholdingPayments, w.GrossEarnings, 
case when w.WithholdingCode = 'EIC' then @AdvPmtAcct else d.GLLiabilityAccount end GLAcctLiability,w.CF
FROM dbo.tblPaCheckWithhold w
Inner Join dbo.tblPaTaxAuthorityHeader h  on w.TaxAuthorityId = h.Id
Inner Join dbo.tblPaTaxAuthorityDetail d on w.TaxAuthorityDtlId = d.Id


CREATE TABLE #tmpTAX (
	[CheckId] [int] NULL ,
	[Id] [int] IDENTITY (1, 1) NOT NULL ,
	[DepartmentId] [pDeptID] NULL ,
	[TaxAuthorityId] int NOT NULL,
	[TaxAuthorityDtlId] int NOT NULL,
	[WithholdingCode] [pCode] NULL ,
	[Description] nvarchar(30) NULL ,
	[WithholdingPayments] [pDecimal] NULL,
	[WithholdingEarnings] [pDecimal] NULL,
	[GrossEarnings] [pDecimal] NULL,
	[CF] [xml] NULL
	)


--INSERT INTO #tmpTAX (CheckId, 
-- DepartmentID, TaxAuthorityId, TaxAuthorityDtlId,
-- WithholdingCode, WithholdingEarnings, WithholdingPayments, GrossEarnings)
--SELECT 
--t.CheckId, l.DepartmentID, t.TaxAuthorityId, t.TaxAuthorityDtlId,
-- t.WithholdingCode, t.WithholdingEarnings, l.AllocTax, t.GrossEarnings 
--FROM dbo.tblPaCheckEmplrTax  t inner join #tmpPaAllocTax l 
--on t.CheckId = l.CheckId and t.TaxAuthorityId = l.TaxAuthorityId 
--AND  t.WithholdingCode = l.WithholdingCode 


INSERT INTO #tmpTAX (CheckId, 
 DepartmentID, TaxAuthorityId, TaxAuthorityDtlId,
 WithholdingCode,  Description, WithholdingEarnings, WithholdingPayments, GrossEarnings,CF)
SELECT 
t.CheckId, l.DepartmentID, t.TaxAuthorityId, t.TaxAuthorityDtlId,
 l.WithholdingCode, t.[Description], l.AllocEarn, l.AllocTax, l.AllocGross,t.CF 
FROM dbo.tblPaCheckEmplrTax  t inner join #tmpPaAllocTax l 
on t.CheckId = l.CheckId and t.TaxAuthorityId = l.TaxAuthorityId 
AND  t.WithholdingCode = l.WithholdingCode 
WHERE (l.AllocEarn + l.AllocTax + l.AllocGross) <> 0


INSERT INTO dbo.tblPaCheckHistEmplrTax (PostRun, CheckId, Id,
DepartmentID, TaxAuthorityType, [State], [Local],[Description], 
WithholdingCode, WithholdingEarnings, WithholdingAmount, GrossEarnings, GLAcctLiability, GLAcctDept,CF)

SELECT @PostRun, t.CheckId, t.Id, t.DepartmentID, h.Type, h.[State], h.[Local], t.Description,
t.WithholdingCode, t.WithholdingEarnings, t.WithholdingPayments, 
t.GrossEarnings, d.GlLiabilityAccount, dd.GlAcct,t.CF 
FROM #tmpTAX t
INNER JOIN #PostTransList b ON t.CheckId = b.TransId
Inner Join dbo.tblPaTaxAuthorityHeader h on t.TaxAuthorityId = h.Id
Inner Join dbo.tblPaTaxAuthorityDetail d on t.TaxAuthorityDtlId = d.Id
Inner Join dbo.tblPaDeptDtl dd  ON dd.DepartmentId = t.DepartmentId and dd.code = t.WithholdingCode
and dd.TaxAuthorityId = t.TaxAuthorityId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateCheckHist_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckPost_UpdateCheckHist_proc';


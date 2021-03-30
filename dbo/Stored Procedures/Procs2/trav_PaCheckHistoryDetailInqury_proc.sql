
CREATE PROCEDURE [dbo].[trav_PaCheckHistoryDetailInqury_proc]
@PostRun pPostRun,
@CheckId int,
@HistType smallint = 1
AS
SET NOCOUNT ON
BEGIN TRY
 
 ----Pet:http://webfront:801/view.php?id=227466
--
--declare @PostRun pPostRun
--declare @CheckId int
--declare @HistType smallint
--
--set @PostRun = '20100608203121'
--set @CheckId = 35
--set @HistType =1

if @HistType = 1

Select e.CheckId, e.EarningCode, ec.Description,  e.DepartmentId, e.EarningsAmount 
from dbo.tblPaCheckHistEarn e inner Join trav_tblPaCheckHist_view p on  e.PostRun = p.PostRun and  
p.Id = e.CheckId Inner Join dbo.tblPaEarnCode ec on ec.Id  = e.EarningCode WHERE                                                                                                                                                                                                                                                 
e.PostRun = @PostRun and e.CheckId = @CheckId
ORDER BY e.CheckId


if @HistType = 2
 
Select  ded.CheckId, ded.DeductionCode, ded.Description,  ded.Hours,  ded.Amount, ded.GLAcctLiability  
From 
(Select d.PostRun,  d.Id,  d.CheckId, d.DeductionCode, dc.Description, null as DepartmentId, d.Hours,  d.Amount, d.GLAcctLiability 
from dbo.tblPaCheckHistDeduct d inner Join trav_tblPaCheckHist_view p on  d.PostRun = p.PostRun and  
p.Id = d.CheckId Inner Join dbo.tblPaDeductCode dc on dc.DeductionCode  = d.DeductionCode and dc.EmployerPaid = 0 
and d.PostRun = @PostRun  and d.CheckId = @CheckId 
)ded 
ORDER BY  ded.CheckId


if @HistType = 3


Select  ded.CheckId, ded.DeductionCode, ded.Description, ded.DepartmentId, ded.Hours,  ded.Amount, ded.GLAcctLiability  
From 
(Select  r.PostRun, r.Id, r.CheckId, r.DeductionCode,  dr.Description, r.DepartmentId, r.Hours, r.Amount, 
r.GLAcctLiability  from dbo.tblPaCheckHistEmplrCost r                                                                                                                                                                                                                                                    
inner Join trav_tblPaCheckHist_view p on  r.PostRun = p.PostRun and  
p.Id = r.CheckId Inner Join dbo.tblPaDeductCode dr on dr.DeductionCode  = r.DeductionCode and dr.EmployerPaid = 1
and r.PostRun = @PostRun and  r.CheckId = @CheckId 
) ded ORDER BY ded.CheckId

if @HistType = 4  

Select wh.CheckId,  wh.TaxAuthorityType, wh.State, wh.Local, 
wh.WithholdingCode, wh.Description, wh.WithholdingAmount, wh.WithholdingEarnings, 
wh.GrossEarnings, wh.GLAcctLiability
from 
(
Select  w.PostRun, w.Id, w.CheckId, null DepartmentId, w.TaxAuthorityType, w.State, w.Local, w.WithholdingCode, w.Description, 
w.WithholdingAmount, w.WithholdingEarnings, w.GrossEarnings, w.GLAcctLiability 
from dbo.tblPaCheckHistWithhold w inner Join trav_tblPaCheckHist_view p on w.PostRun = p.PostRun and  
p.Id = w.CheckId and w.PostRun = @PostRun and  w.CheckId = @CheckId  and @HistType = 4   
) wh 
ORDER BY  Wh.CheckId


if @HistType = 5

Select wh.CheckId, wh.DepartmentId, wh.TaxAuthorityType, wh.State, wh.Local, 
wh.WithholdingCode, wh.Description, wh.WithholdingAmount, wh.WithholdingEarnings, 
wh.GrossEarnings, wh.GLAcctLiability
from 
( Select  x.PostRun, x.Id, x.CheckId, x.DepartmentId, x.TaxAuthorityType, 
x.State, x.Local, x.WithholdingCode, x.Description, x.WithholdingAmount, 
x.WithholdingEarnings, x.GrossEarnings, x.GLAcctLiability
from dbo.tblPaCheckHistEmplrTax x  
inner Join trav_tblPaCheckHist_view p on  x.PostRun = p.PostRun and  
p.Id = x.CheckId and x.PostRun = @PostRun and  x.CheckId = @CheckId and @HistType = 5
) wh 
ORDER BY  Wh.CheckId


if @HistType = 6

Select  l.CheckId, l.LeaveCodeId, lc.Description, l.HoursAccrued
from dbo.tblPaCheckHistLeave l
inner Join trav_tblPaCheckHist_view p on l.PostRun = p.PostRun and  
p.Id = l.CheckId  Inner Join dbo.tblPaLeaveCodeHdr lc on l.LeaveCodeId = lc.Id  
and l.PostRun = @PostRun and l.CheckId = @CheckId and @HistType = 6                                                                                                                                                                                                                                                   
ORDER BY  l.Id




END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryDetailInqury_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryDetailInqury_proc';


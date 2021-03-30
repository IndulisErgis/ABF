
CREATE PROCEDURE [dbo].[trav_PaCheckHistoryWHDetailInqury_proc]
@PostRun pPostRun,
@CheckId int
--,
--@HistType smallint = 2
AS
SET NOCOUNT ON
BEGIN TRY
 
--
--declare @PostRun pPostRun
--declare @CheckId int
--declare @HistType smallint
--
--set @PostRun = '20100608203121'
--set @CheckId = 35
--set @HistType =1


Select * 
from 

(Select wh.Type, wh.CheckId, wh.DepartmentId, wh.TaxAuthorityType, wh.State, wh.Local, 
wh.WithholdingCode, wh.Description, wh.WithholdingAmount, wh.WithholdingEarnings, 
wh.GrossEarnings, wh.GLAcctLiability
from 
(
Select 2 as Type, w.PostRun, w.Id, w.CheckId, null DepartmentId, w.TaxAuthorityType, w.State, w.Local, w.WithholdingCode, w.Description, 
w.WithholdingAmount, w.WithholdingEarnings, w.GrossEarnings, w.GLAcctLiability 
from dbo.tblPaCheckHistWithhold w inner Join trav_tblPaCheckHist_view p on w.PostRun = p.PostRun and  
p.Id = w.CheckId and w.PostRun = @PostRun and  w.CheckId = @CheckId   
Union All
Select 3 as Type, x.PostRun, x.Id, x.CheckId, x.DepartmentId, x.TaxAuthorityType, 
x.State, x.Local, x.WithholdingCode, x.Description, x.WithholdingAmount, 
x.WithholdingEarnings, x.GrossEarnings, x.GLAcctLiability
from dbo.tblPaCheckHistEmplrTax x  
inner Join trav_tblPaCheckHist_view p on  x.PostRun = p.PostRun and  
p.Id = x.CheckId and x.PostRun = @PostRun and  x.CheckId = @CheckId
) wh 
--WHERE ((wh.PostRun = @PostRun  and wh.CheckId = @CheckId))
               
)Wht
--WHERE Wht.HistType = @HistType
ORDER BY  Wht.CheckId
--
--
--
--Select 4 as HistType, l.PostRun, l.Id, l.CheckId, l.LeaveCodeId, lc.Description, l.HoursAccrued
--from dbo.tblPaCheckHistLeave l
--inner Join trav_tblPaCheckHist_view p on l.PostRun = p.PostRun and  
--p.Id = l.CheckId  Inner Join dbo.tblPaLeaveCodeHdr lc on l.LeaveCodeId = lc.Id                                                                                                                                                                                                                                                      
--WHERE ((l.PostRun = @PostRun and l.CheckId = @CheckId and @HistType = 4))
--ORDER BY  l.Id

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryWHDetailInqury_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryWHDetailInqury_proc';


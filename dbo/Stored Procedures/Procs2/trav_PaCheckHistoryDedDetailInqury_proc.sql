
CREATE PROCEDURE [dbo].[trav_PaCheckHistoryDedDetailInqury_proc]
@PostRun pPostRun,
@CheckId int
--,
--@HistType smallint
AS
SET NOCOUNT ON
BEGIN TRY
 

--declare @PostRun pPostRun
--declare @CheckId int
--declare @HistType smallint
--
--set @PostRun = '20100608203121'
--set @CheckId = 35
--set @HistType =1


 Select * 
from 
(
Select ded.Type, ded.CheckId, ded.DeductionCode, ded.Description, ded.DepartmentId, ded.Hours,  ded.Amount, ded.GLAcctLiability  
From 
(Select 0 as Type,  d.PostRun,  d.Id,  d.CheckId, d.DeductionCode, dc.Description, null as DepartmentId, d.Hours,  d.Amount, d.GLAcctLiability 
from dbo.tblPaCheckHistDeduct d inner Join trav_tblPaCheckHist_view p on  d.PostRun = p.PostRun and  
p.Id = d.CheckId Inner Join dbo.tblPaDeductCode dc on dc.DeductionCode  = d.DeductionCode and dc.EmployerPaid = 0
Union All
Select 1 as Type, r.PostRun, r.Id, r.CheckId, r.DeductionCode,  dr.Description, r.DepartmentId, r.Hours, r.Amount, 
r.GLAcctLiability  from dbo.tblPaCheckHistEmplrCost r                                                                                                                                                                                                                                                    
inner Join trav_tblPaCheckHist_view p on  r.PostRun = p.PostRun and  
p.Id = r.CheckId Inner Join dbo.tblPaDeductCode dr on dr.DeductionCode  = r.DeductionCode and dr.EmployerPaid = 1) ded
WHERE ((ded.PostRun = @PostRun  and ded.CheckId = @CheckId ))
)deduct 
--WHERE deduct.HistType = @HistType
ORDER BY  deduct.CheckId

--ded.PostRun, ded.Id,  
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryDedDetailInqury_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryDedDetailInqury_proc';



CREATE PROCEDURE [dbo].[trav_PaCheckHistoryEarnDetailInqury_proc]
@PostRun pPostRun,
@CheckId int
--,
--@HistType smallint 
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
(
Select e.CheckId, e.EarningCode, ec.Description,  e.DepartmentId, e.EarningsAmount 
from dbo.tblPaCheckHistEarn e inner Join trav_tblPaCheckHist_view p on  e.PostRun = p.PostRun and  
p.Id = e.CheckId Inner Join dbo.tblPaEarnCode ec on ec.Id  = e.EarningCode WHERE                                                                                                                                                                                                                                                 
(e.PostRun = @PostRun and e.CheckId = @CheckId )
)ern  
--WHERE ern.HistType = @HistType 
ORDER BY ern.CheckId


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryEarnDetailInqury_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaCheckHistoryEarnDetailInqury_proc';


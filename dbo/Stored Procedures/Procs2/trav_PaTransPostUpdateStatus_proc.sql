

CREATE PROCEDURE dbo.trav_PaTransPostUpdateStatus_proc
AS

BEGIN TRY

	SET NOCOUNT ON

	DECLARE @PostRun pPostRun

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	
	IF  @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	UPDATE dbo.tblPaTransEarn  SET PostedYn =1,PostRun =@PostRun
	FROM dbo.tblPaTransEarn e 
	INNER JOIN (SELECT TransId FROM #PostTransDetail WHERE DetailType =0) p
	ON e.Id=p.TransId

	UPDATE dbo.tblPaTransDeduct  SET PostedYn =1,PostRun =@PostRun
	FROM dbo.tblPaTransDeduct d 
	INNER JOIN (SELECT TransId FROM #PostTransDetail WHERE DetailType =1) p
	ON d.Id=p.TransId

	UPDATE dbo.tblPaTransEmplrCost  SET PostedYn =1,PostRun =@PostRun
	FROM dbo.tblPaTransEmplrCost e 
	INNER JOIN (SELECT TransId FROM #PostTransDetail WHERE DetailType =2) p
	ON e.Id=p.TransId

END TRY

BEGIN CATCH

	EXEC dbo.trav_RaiseError_proc

END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPostUpdateStatus_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PaTransPostUpdateStatus_proc';


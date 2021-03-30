
CREATE PROCEDURE dbo.trav_PcAdjustmentPost_RemoveAdjustments_proc
AS
BEGIN TRY

	DELETE dbo.tblPcAdjustment
	FROM #PostTransList t INNER JOIN dbo.tblPcAdjustment ON t.TransId = dbo.tblPcAdjustment.Id
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentPost_RemoveAdjustments_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentPost_RemoveAdjustments_proc';


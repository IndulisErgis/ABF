
CREATE PROCEDURE dbo.trav_PcOhAllocPost_RemovePrepareOh_proc
AS
BEGIN TRY

	DELETE dbo.tblPcPrepareOverhead
	FROM #PostTransList t INNER JOIN dbo.tblPcPrepareOverhead ON t.TransId = dbo.tblPcPrepareOverhead.Id
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_RemovePrepareOh_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcOhAllocPost_RemovePrepareOh_proc';


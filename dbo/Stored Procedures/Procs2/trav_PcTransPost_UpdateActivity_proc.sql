
CREATE PROCEDURE dbo.trav_PcTransPost_UpdateActivity_proc
AS
BEGIN TRY

	UPDATE dbo.tblPcActivity SET [Status] = 2 --Posted
		, [CF] = m.[CF]
	FROM #PostTransList t INNER JOIN dbo.tblPcTrans m ON t.TransId = m.Id
		INNER JOIN dbo.tblPcActivity ON m.ActivityId = dbo.tblPcActivity.Id
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_UpdateActivity_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTransPost_UpdateActivity_proc';


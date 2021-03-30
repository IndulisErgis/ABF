
CREATE PROCEDURE dbo.trav_InTransferPost_Clear_proc
AS
BEGIN TRY
	DELETE FROM dbo.tblInXFers
		WHERE TransId IN (SELECT TransId FROM #PostTransList)
	DELETE FROM dbo.tblInXferLot
		WHERE TransId IN (SELECT TransId FROM #PostTransList)		
	DELETE FROM dbo.tblInXferSer
		WHERE TransId IN (SELECT TransId FROM #PostTransList)	
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_Clear_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTransferPost_Clear_proc';


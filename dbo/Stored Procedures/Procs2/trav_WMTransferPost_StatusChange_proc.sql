
CREATE PROCEDURE [dbo].[trav_WMTransferPost_StatusChange_proc]
AS
BEGIN TRY  
    -- Uupdate status  1= Posted 
    --Update Pick   
	UPDATE dbo.tblWmTransferPick  SET [Status]= 1 FROM #WMTranferPost t
	INNER JOIN dbo.tblWmTransferPick p ON t.TransType = 0 AND p.[Status] = 0 AND t.TranPickKey = p.TranPickKey
	--Update Receipt		
	UPDATE dbo.tblWmTransferRcpt  SET [Status]= 1 FROM #WMTranferPost t 
	INNER JOIN dbo.tblWmTransferPick p ON t.TransType = 1 AND t.TranPickKey = p.TranPickKey
	INNER JOIN dbo.tblWmTransferRcpt r ON r.[Status] = 0 AND p.TranPickKey = r.TranPickKey
 
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_StatusChange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_StatusChange_proc';


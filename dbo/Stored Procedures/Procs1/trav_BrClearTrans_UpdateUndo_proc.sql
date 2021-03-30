
CREATE PROCEDURE dbo.trav_BrClearTrans_UpdateUndo_proc 
@BankId nvarchar(10),
@StatementId bigint =0
AS
BEGIN TRY

UPDATE dbo.tblBrMaster SET ClearedYn = 0, StatementID =NULL
FROM dbo.tblBrMaster INNER JOIN dbo.tblBrClearedTrans c ON dbo.tblBrMaster.EntryNum = c.ClearedEntryNum
WHERE dbo.tblBrMaster.BankID = @BankID AND dbo.tblBrMaster.ClearedYn = 1 AND dbo.tblBrMaster.VoidStop = 0 AND dbo.tblBrMaster.StatementID =@StatementId

UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum  = NULL
FROM dbo.tblBrClearedTrans INNER JOIN dbo.tblBrMaster m ON dbo.tblBrClearedTrans.ClearedEntryNum = m.EntryNum 
WHERE m.BankID = @BankID AND m.ClearedYn = 0 AND  m.StatementID IS NULL
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrClearTrans_UpdateUndo_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrClearTrans_UpdateUndo_proc';


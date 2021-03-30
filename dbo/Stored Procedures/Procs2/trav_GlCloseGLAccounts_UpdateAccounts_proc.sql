
CREATE PROCEDURE dbo.trav_GlCloseGLAccounts_UpdateAccounts_proc
AS
BEGIN TRY

	UPDATE tblGlAcctHdr SET [Status] = 1
	FROM tblGlAcctHdr g INNER JOIN #AccountList a
		ON g.AcctId = a.AccountId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCloseGLAccounts_UpdateAccounts_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlCloseGLAccounts_UpdateAccounts_proc';


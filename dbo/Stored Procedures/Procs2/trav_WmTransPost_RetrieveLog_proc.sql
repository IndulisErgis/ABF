
CREATE PROCEDURE dbo.trav_WmTransPost_RetrieveLog_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	--remap values from the gl post log for the post log
	SELECT [LogKey] AS [ID]
		, [FiscalYear], [FiscalPeriod]
		, [ItemId], [LocId], ISNULL([LinkIdSubLine], 0) AS [TransType]
		, [GlAccount], [Grouping], [DebitAmount], [CreditAmount]
		, [Description], [Reference]
	FROM #GlPostLogs
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_RetrieveLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WmTransPost_RetrieveLog_proc';


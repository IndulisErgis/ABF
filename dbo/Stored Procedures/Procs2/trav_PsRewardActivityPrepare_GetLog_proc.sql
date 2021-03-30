
CREATE PROCEDURE dbo.trav_PsRewardActivityPrepare_GetLog_proc 
AS
SET NOCOUNT ON
BEGIN TRY

	--Retrieve data for the Activity log
	SELECT MIN(r.[ID])
		, r.[ActivityGroup]
		, r.[ProgramID], p.[Description]
		, r.[AccountID], a.[RewardNumber], a.[Name] AS [AccountName]
		, SUM(r.[PointQty]) AS [PointQty], SUM(r.[PointValue]) AS [PointValue]
	FROM #AccrualActivity r
		LEFT JOIN dbo.tblPsRewardAccount a ON r.[AccountID] = a.[ID]
		LEFT JOIN dbo.tblPsRewardProgram p ON r.[ProgramID] = p.[ID]
	GROUP BY r.[ProgramID], r.[AccountID], r.[ActivityGroup]
		, p.[Description], a.[RewardNumber], a.[Name]
	HAVING SUM(r.[PointQty]) <> 0 OR SUM(r.[PointValue]) <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_GetLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_GetLog_proc';


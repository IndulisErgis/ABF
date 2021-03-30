
CREATE PROCEDURE dbo.trav_PsRewardActivityPrepare_Generate_proc 
AS
SET NOCOUNT ON
BEGIN TRY

	--Retrieve global values
	DECLARE	@WrkStnDate datetime
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	DECLARE @MaxActivityID bigint
	SELECT @MaxActivityID = MAX([ID]) FROM dbo.tblPsRewardActivity
	SELECT @MaxActivityID = ISNULL(@MaxActivityID, 0)

	--generate activity records for the accruals
	INSERT INTO dbo.tblPsRewardActivity ([ID], [ProgramID], [AccountID], [Type]
		, [TransDate], [EntryDate], [PointQty], [PointValue], [ActivityGroup]
		, [FiscalYear], [FiscalPeriod], [LiabilityAccount], [GLAccount], [Synched])
	SELECT MIN(a.[ID]) + @MaxActivityID, a.[ProgramID], a.[AccountID], 0
		, @WrkStnDate, GetDate(), SUM(a.[PointQty]), SUM(a.[PointValue]), a.[ActivityGroup]
		, 0, 0, p.[LiabilityAccount], p.[ExpenseAccount], 0
	FROM #AccrualActivity a
	INNER JOIN dbo.tblPsRewardProgram p on a.[ProgramID] = p.[ID]
	GROUP BY a.[ProgramID], a.[AccountID], a.[ActivityGroup], p.[LiabilityAccount], p.[ExpenseAccount]
	HAVING SUM(a.[PointQty]) <> 0 OR SUM(a.[PointValue]) <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_Generate_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_Generate_proc';


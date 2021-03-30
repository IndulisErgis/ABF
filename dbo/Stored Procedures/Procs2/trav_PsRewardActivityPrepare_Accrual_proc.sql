
CREATE PROCEDURE dbo.trav_PsRewardActivityPrepare_Accrual_proc 
AS
SET NOCOUNT ON
BEGIN TRY
	--populates a temporary table that supports the following
	--CREATE TABLE #AccrualActivity
	--(
	--	[ID] [bigint] IDENTITY(1, 1),
	--	[ActivityGroup] [pPostRun],
	--	[ProgramID] [bigint],
	--	[AccountID] [bigint],
	--	[PointQty] [pDecimal],
	--	[PointValue] [pDecimal]
	--)

	--Retrieve global values
	DECLARE	@PrecCurr smallint, @WrkStnDate datetime
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	--Collect and evaluate the accruals available to the reward accounts for the identified history records
	--	Each account may be eligible for multiple reward programs
	INSERT INTO #AccrualActivity ([ActivityGroup], [ProgramID], [AccountID]
		, [PointQty], [PointValue])
	SELECT h.[PostRun], p.[ID], a.[ID]
		, CASE p.[Type] 
			WHEN 0 THEN d.[Qty] * p.[PointAccrualRate] / 100.0  --per unit
			WHEN 1 THEN d.[ExtPrice] * p.[PointAccrualRate] / 100.0 --per dollar
			ELSE 0 
		END 
		, ROUND(p.[PointValue] * CASE p.[Type] 
			WHEN 0 THEN d.[Qty] * p.[PointAccrualRate] / 100.0  --per unit
			WHEN 1 THEN d.[ExtPrice] * p.[PointAccrualRate] / 100.0 --per dollar
			ELSE 0 
		END, @PrecCurr)
	FROM #HistoryList l
		INNER JOIN dbo.tblPsHistHeader h ON l.[ID] = h.[ID]
		INNER JOIN dbo.tblPsHistDetail d ON h.[ID] = d.[HeaderID]
		INNER JOIN dbo.tblPsRewardAccount a ON h.[RewardNumber] = a.[RewardNumber]
		CROSS JOIN dbo.tblPsRewardProgram p 
	WHERE p.[Status] = 0 --active programs
		AND p.[PointAccrualRate] <> 0 --with an accrual rate
		AND ISNULL(p.StartDate, h.TransDate) <= h.TransDate AND ISNULL(p.EndDate, h.TransDate) >= h.TransDate --within transactions in the program date range
		AND d.[LineType] = 1 --only process regular line item types


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_Accrual_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsRewardActivityPrepare_Accrual_proc';


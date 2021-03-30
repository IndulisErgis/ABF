
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_GetCycles]
(
	@CycleIds IntegerListType READONLY
)
AS
BEGIN
	SELECT
		[c].[CycleId],
		[c].[Cycle],
		[c].[Desc],
		[c].[UOM],
		[c].[Units],
		[c].[PermanentYN],
		[c].[InactiveYN],
		[c].[ts]
	FROM	[dbo].[ALP_tblArAlpCycle] AS [c]
	INNER JOIN @CycleIds AS [input]
		ON	[input].[Id] = [c].[CycleId]
END
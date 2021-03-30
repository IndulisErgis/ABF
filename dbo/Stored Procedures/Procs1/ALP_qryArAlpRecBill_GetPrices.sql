
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_GetPrices]
(
	@RecBillServPriceIds IntegerListType READONLY
)
AS
BEGIN
	SELECT
		[p].[RecBillServPriceId],
		[p].[RecBillServId],
		[p].[StartBillDate],
		[p].[EndBillDate],
		[p].[Price],
		[p].[UnitCost],
		[p].[RMR],
		[p].[RMRChange],
		[p].[Reason],
		[p].[JobOrdNum],
		[p].[ActiveYn],
		[p].[ts],
		[p].[PriceLockedYn],
		[p].[ModifiedBy],
		[p].[ModifiedDate]
	FROM	[dbo].[ALP_tblArAlpSiteRecBillServPrice] AS [p]
	INNER JOIN @RecBillServPriceIds AS [input]
		ON	[input].[Id] = [p].[RecBillServPriceId]
END
CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBillServPriceGetByRecBillServIds]
(
	@RecBillServIds IntegerListType READONLY
)
AS
BEGIN
	SELECT
		[rbsp].[RecBillServPriceId],
		[rbsp].[RecBillServId],
		[rbsp].[StartBillDate],
		[rbsp].[EndBillDate],
		[rbsp].[Price],
		[rbsp].[UnitCost],
		[rbsp].[RMR],
		[rbsp].[RMRChange],
		[rbsp].[Reason],
		[rbsp].[JobOrdNum],
		[rbsp].[ActiveYn],
		[rbsp].[ts],
		[rbsp].[PriceLockedYn],
		[rbsp].[ModifiedBy],
		[rbsp].[ModifiedDate]
	FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [rbsp]
	INNER JOIN @RecBillServIds AS [input]
		ON	[input].[Id] = [rbsp].[RecBillServId]
END
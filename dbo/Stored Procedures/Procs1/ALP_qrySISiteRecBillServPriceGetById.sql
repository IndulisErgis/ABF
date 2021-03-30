
CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBillServPriceGetById]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@RecBillServPriceId int
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
	WHERE [rbsp].[RecBillServPriceId] = @RecBillServPriceId
END
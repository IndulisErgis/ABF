CREATE VIEW [dbo].[ALP_tblArAlpSiteRecBillServPrice_view]
AS
SELECT
	[RecBillServPriceId],
	[RecBillServId],
	[StartBillDate],
	[EndBillDate],
	[Price],
	[UnitCost],
	[RMR],
	[RMRChange],
	[Reason],
	[JobOrdNum],
	[ActiveYn],
	[ts],
	[PriceLockedYn],
	[ModifiedBy],
	[ModifiedDate]
FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice]
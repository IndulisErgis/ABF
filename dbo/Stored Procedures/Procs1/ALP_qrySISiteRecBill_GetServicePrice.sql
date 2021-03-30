CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBill_GetServicePrice]  
-- Created by Nidheesh on 05/19/09
-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
(  
	@RecBillServId int,
	@EffectiveDate datetime
)  
AS
BEGIN
	SELECT
		[sp].[RecBillServPriceId],
		[sp].[RecBillServId],
		[sp].[StartBillDate],
		[sp].[EndBillDate],
		[sp].[Price],
		[sp].[UnitCost],
		[sp].[RMR],
		[sp].[RMRChange],
		[sp].[Reason],
		[sp].[JobOrdNum],
		[sp].[ActiveYn],
		[sp].[ts],
		[sp].[PriceLockedYn]
	FROM [dbo].[ALP_tblArAlpSiteRecBillServPrice_view] AS [sp]
	WHERE	[sp].[RecBillServId] = @RecBillServId    
		AND	(([sp].[StartBillDate] <= @EffectiveDate )  AND ([sp].[StartBillDate] IS NOT NULL OR [sp].[StartBillDate] <> ''))
		AND ([sp].[EndBillDate] > @EffectiveDate OR [sp].[EndBillDate] IS NULL)
end
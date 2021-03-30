CREATE FUNCTION [dbo].[ALP_ufxArAlpSite_HasPendingService]
(
	@SiteId INT
)
RETURNS BIT
AS
BEGIN
	DECLARE @Exists BIT
	SET @Exists = 0
	IF EXISTS( 
		SELECT 1
		FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]
		INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS rb
			ON	[rb].[RecBillId] = [rbs].[RecBillId]
		WHERE	[rb].[SiteId] = @SiteId
			AND	[rbs].[RecBillId] = [rb].[RecBillId]
			AND	[rbs].[ServiceStartDate] IS NULL
			AND	[rbs].[Status] NOT IN ('Expired', 'Cancelled')
	)
	BEGIN
		SET @Exists = 1
	END
	RETURN @Exists
END
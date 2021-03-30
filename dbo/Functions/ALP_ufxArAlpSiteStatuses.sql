CREATE FUNCTION [dbo].[ALP_ufxArAlpSiteStatuses]
(
	@SiteIds IntegerListType READONLY
)
RETURNS 
@Statuses TABLE
(
	[SiteId] INT NOT NULL,
	[Status] VARCHAR(20)
)
AS
BEGIN
	INSERT INTO @Statuses
	SELECT 
	[s].[SiteId],
	[s].[Status]
	FROM	[dbo].[ALP_tblArAlpSite] AS [s]
	INNER JOIN @SiteIds AS [input]
		ON	[s].[SiteId] = [input].[Id]
	
	UPDATE t
	SET	[Status] = 'Pending'
	FROM @Statuses as [t]
	WHERE	[t].[Status] NOT IN ('Prospect', 'Dead', 'Pending')
		AND	1 = [dbo].[ALP_ufxArAlpSite_HasPendingService]([t].[SiteId]) -- Has pending services
		AND 0 = [dbo].[ALP_ufxArAlpSite_HasActiveService]([t].[SiteId]) -- Does not have active services
		
	UPDATE t
	SET	[Status] = 'Inactive'
	FROM @Statuses as [t]
	WHERE	[t].[Status] NOT IN ('Prospect', 'Dead', 'Inactive')
		AND	0 = [dbo].[ALP_ufxArAlpSite_HasPendingService]([t].[SiteId]) -- Does not have pending services
		AND 0 = [dbo].[ALP_ufxArAlpSite_HasActiveService]([t].[SiteId]) -- Does not have active services
	
	UPDATE t
	SET [Status] = 'Active'
	FROM @Statuses as [t]
	WHERE	[t].[Status] NOT IN ('Prospect', 'Dead', 'Active')
		AND	1 = [dbo].[ALP_ufxArAlpSite_HasActiveService]([t].[SiteId]) -- Has have active services
	RETURN
END
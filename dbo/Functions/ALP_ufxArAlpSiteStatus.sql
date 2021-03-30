CREATE FUNCTION [dbo].[ALP_ufxArAlpSiteStatus]
/* created 08/19/04 EFI 1469  MAH				*/
/* 	- determines the status of a site			*/
/*	- used in code and sprocs to update the site status	*/
--MAH 07/11/06 - bypass expired and cancelled services when checking for pending items.
-- JCG 08/15/2013 - consuming new table-valued function

(
	@SiteId int = null
)
RETURNS varchar(20)
AS
BEGIN
DECLARE @SiteIds IntegerListType
INSERT INTO @SiteIds
(Id)
VALUES
(@SiteId)

DECLARE @Status varchar(20)
SELECT @Status = [Status]
FROM	[dbo].[ALP_ufxArAlpSiteStatuses](@SiteIds)
RETURN @Status
END
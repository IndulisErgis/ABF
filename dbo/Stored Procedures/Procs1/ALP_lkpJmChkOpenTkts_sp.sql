
CREATE  procedure dbo.ALP_lkpJmChkOpenTkts_sp
	(
	@SiteID integer = 0
	)
AS
SELECT TicketId 
FROM        dbo.ALP_tblJmSvcTkt
WHERE dbo.ALP_tblJmSvcTkt.SiteId = @SiteID and dbo.ALP_tblJmSvcTkt.Status <> 'Closed' AND  dbo.ALP_tblJmSvcTkt.Status <>'Canceled'
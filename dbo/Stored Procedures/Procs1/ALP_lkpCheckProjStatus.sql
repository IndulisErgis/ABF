
CREATE Procedure dbo.ALP_lkpCheckProjStatus
(@ProjectID varchar(10),
	@SiteID int = 0 )
AS
SELECT count(TicketId) as OpenJobCount FROM dbo.ALP_tblJmSvcTkt 
WHERE SiteID = @SiteID AND Status <> 'Closed' AND 
Status <> 'Canceled'  AND 
ProjectId = @ProjectID
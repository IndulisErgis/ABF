

CREATE function [dbo].[ALP_ufxJmComm_CheckProjStatus]
(
	@ProjectID varchar(10)
)
returns varchar(8)
AS
BEGIN
declare @ProjStatus varchar(8)
declare @UniqueInvcNum varchar(10)
SET @ProjStatus = 'Complete'
IF EXISTS (SELECT ST.TicketID   
	   FROM dbo.ALP_tblJmSvcTkt ST
	   WHERE  ST.ProjectID = @ProjectID
		AND ST.Status IN ('New', 'Scheduled','Targeted'))
BEGIN
	SET @ProjStatus = 'Open'
END
ELSE
BEGIN
	IF EXISTS (SELECT ST.TicketID   
	   FROM dbo.ALP_tblJmSvcTkt ST
	   WHERE  ST.ProjectID = @ProjectID
		AND ST.Status <> 'Canceled'
		AND dbo.ALP_ufxJmComm_CheckInvcStatus(ST.InvcNum) <> 'PAID'
		)
	BEGIN
		SET @ProjStatus = 'Complete'
	END
	ELSE
	BEGIN
		SET @ProjStatus = 'Paid'
	END
END
RETURN @ProjStatus
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckProjStatus] TO [JMCommissions]
    AS [dbo];


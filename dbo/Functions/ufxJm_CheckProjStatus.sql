CREATE function dbo.ufxJm_CheckProjStatus
(
	@ProjectID varchar(10)
)
returns varchar(8)
AS
BEGIN
declare @ProjStatus varchar(8)
SET @ProjStatus = 'Complete'
IF EXISTS (SELECT ST.TicketID   
	   FROM dbo.tblJmSvcTkt ST
	   WHERE  ST.ProjectID = @ProjectID
		AND ST.Status IN ('New', 'Scheduled','Targeted'))
BEGIN
	SET @ProjStatus = 'Open'
END
ELSE
BEGIN
	IF EXISTS (SELECT ST.TicketID   
	   FROM dbo.tblJmSvcTkt ST
	   WHERE  ST.ProjectID = @ProjectID
		AND ST.Status <> 'Canceled'
		)
	BEGIN
		SET @ProjStatus = 'Complete'
	END
END
RETURN @ProjStatus
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_CheckProjStatus] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_CheckProjStatus] TO PUBLIC
    AS [dbo];


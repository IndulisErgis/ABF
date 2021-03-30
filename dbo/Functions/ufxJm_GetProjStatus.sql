
CREATE function dbo.ufxJm_GetProjStatus
(
	@ProjectID varchar(10)
)
returns varchar(10)
AS
BEGIN
declare @ProjStatus varchar(10)
SET @ProjStatus = 'Completed'
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
		SET @ProjStatus = 'Completed'
	END
END
RETURN @ProjStatus
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_GetProjStatus] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJm_GetProjStatus] TO PUBLIC
    AS [dbo];



CREATE  procedure dbo.ALP_stpJmSvcTkt_sp
@TicketId int

As
Set Nocount on

If @TicketID is Null
	BEGIN
		SELECT *
		FROM dbo.ALP_tblJmSvcTkt
	END
ELSE
	BEGIN
		SELECT *
		FROM dbo.ALP_tblJmSvcTkt
		WHERE TicketID = @TicketID
	END
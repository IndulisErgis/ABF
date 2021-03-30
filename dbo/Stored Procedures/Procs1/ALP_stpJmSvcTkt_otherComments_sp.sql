
CREATE  procedure dbo.ALP_stpJmSvcTkt_otherComments_sp
	@TicketId int
As
Set Nocount on
	BEGIN
		SELECT OtherComments
		FROM dbo.ALP_tblJmSvcTkt
		WHERE TicketID = @TicketID
	END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_stpJmSvcTkt_otherComments_sp] TO PUBLIC
    AS [dbo];




CREATE PROCEDURE dbo.ALP_stpJmSvcTktCommSplit_sp
	(
	@TicketID int = null
	)
AS
SELECT     TicketID, SalesRep, CommSplitPct, CommAmt, JobShare,Comments,CommSplitID
FROM         dbo.ALP_tblJmSvcTktCommSplit
WHERE TicketID = @TicketID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_stpJmSvcTktCommSplit_sp] TO PUBLIC
    AS [dbo];


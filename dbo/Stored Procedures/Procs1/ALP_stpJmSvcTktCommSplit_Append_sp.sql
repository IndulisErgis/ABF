



CREATE PROCEDURE [dbo].[ALP_stpJmSvcTktCommSplit_Append_sp]
	(
	@TicketID int = 0,
	@SalesRep varchar(3),
	@CommAmt pDec = 0
	)
AS
set nocount on
If exists (SELECT TicketID 
		FROM dbo.ALP_tblJmSvcTktCommSplit 
		WHERE TicketID = @TicketID
		AND SalesRep = @SalesRep)
	BEGIN
		SELECT Count(TicketID) as CommSplitCount 
		FROM dbo.ALP_tblJmSvcTktCommSplit 
		WHERE TicketID = @TicketID
	END
ELSE
	BEGIN
		-- If and else condition added by NSK on 9th May 2014 to check if the ticket id already has sales rep
		If exists (SELECT TicketID 
			FROM dbo.ALP_tblJmSvcTktCommSplit 
			where TicketID = @TicketID AND SalesRep <> @SalesRep)
		BEGIN
			INSERT INTO dbo.ALP_tblJmSvcTktCommSplit
			(TicketID, SalesRep, CommSplitPct, CommAmt, JobShare)
			VALUES (@TicketID, @SalesRep, 0,0, 0)
			
			SELECT Count(TicketID) as CommSplitCount 
			FROM dbo.ALP_tblJmSvcTktCommSplit 
			WHERE TicketID = @TicketID		
		END
		Else
			INSERT INTO dbo.ALP_tblJmSvcTktCommSplit
			(TicketID, SalesRep, CommSplitPct, CommAmt, JobShare)
			VALUES (@TicketID, @SalesRep, 100,@CommAmt, 100)
			
			SELECT Count(TicketID) as CommSplitCount 
			FROM dbo.ALP_tblJmSvcTktCommSplit 
			WHERE TicketID = @TicketID		
	END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_stpJmSvcTktCommSplit_Append_sp] TO PUBLIC
    AS [dbo];


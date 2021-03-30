

CREATE PROCEDURE [dbo].[ALP_stpJmSvcTktCommSplit_Update_sp]
--EFI# 1528 MAH 11/17/04 - created
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	(
	@TicketID int = 0,
	@CommAmt pDec = 0,
	@ModifiedBy varchar(50)
	)
AS
set nocount on
UPDATE dbo.ALP_tblJmSvcTktCommSplit 
SET  CommAmt = @CommAmt,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
WHERE TicketID = @TicketID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_stpJmSvcTktCommSplit_Update_sp] TO PUBLIC
    AS [dbo];


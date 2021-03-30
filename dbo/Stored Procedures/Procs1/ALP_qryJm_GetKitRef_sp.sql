
CREATE PROCEDURE dbo.ALP_qryJm_GetKitRef_sp 
	( @TicketID int = 0,
	@LineNumber varchar(50) = '',
	@TicketItemID int output
	)
AS
Set @TicketItemID = 0
SET @TicketItemID = (
	SELECT     TicketItemId
	FROM         ALP_tblJmSvcTktItem
	WHERE     (LineNumber = @LineNumber) AND (TicketId = @TicketID)
	)
IF @TicketItemID is null
BEGIN
	SET @TicketItemID = 0 
END
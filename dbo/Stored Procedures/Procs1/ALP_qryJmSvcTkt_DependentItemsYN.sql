


create PROCEDURE dbo.ALP_qryJmSvcTkt_DependentItemsYN 
(
	@ID int,
	@Result bit = 0 output
)
As
SET NOCOUNT ON
SET @Result = 0
if exists (SELECT ALP_tblJmSvcTktItem.TicketId
		FROM ALP_tblJmSvcTktItem 
		WHERE ALP_tblJmSvcTktItem.TicketId = @ID )
BEGIN
	SET @Result = 1
END
ELSE
BEGIN
	SET @Result = 0
END
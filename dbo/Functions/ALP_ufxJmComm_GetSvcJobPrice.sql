
CREATE function [dbo].[ALP_ufxJmComm_GetSvcJobPrice]
(
	@TicketID int
)
returns pDec
AS
BEGIN
RETURN
(SELECT SUM(JobPrice) 
	FROM dbo.ALP_stpJm0021SvcJobPrice
	WHERE TicketID = @TicketID
) 
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_GetSvcJobPrice] TO [JMCommissions]
    AS [dbo];


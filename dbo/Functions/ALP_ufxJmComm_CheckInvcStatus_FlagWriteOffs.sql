
CREATE FUNCTION [dbo].[ALP_ufxJmComm_CheckInvcStatus_FlagWriteOffs]
(
	@InvcNum varchar(10)
)
returns bit
AS
BEGIN
declare @Flagged bit

SET @Flagged = 0
IF EXISTS (SELECT P.PmtMethodId
		FROM  tblArHistPmt P INNER JOIN ALP_tmpJmComm_FlaggedPaymentMethods F
		ON P.PmtMethodId = F.PaymentMethodId
		WHERE (InvcNum = @InvcNum)
		)
BEGIN
	SET @Flagged = 1
END
RETURN @Flagged
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_ufxJmComm_CheckInvcStatus_FlagWriteOffs] TO [JMCommissions]
    AS [dbo];


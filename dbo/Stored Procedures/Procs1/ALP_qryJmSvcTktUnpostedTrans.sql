
CREATE PROCEDURE dbo.ALP_qryJmSvcTktUnpostedTrans
@ID int --TicketID
As
SET NOCOUNT ON
SELECT ALP_tblArTransHeader.AlpJobNum, ALP_tblArTransHeader.AlpSvcYN
FROM ALP_tblArTransHeader
WHERE ALP_tblArTransHeader.AlpJobNum = @ID AND ALP_tblArTransHeader.AlpSvcYN = 1
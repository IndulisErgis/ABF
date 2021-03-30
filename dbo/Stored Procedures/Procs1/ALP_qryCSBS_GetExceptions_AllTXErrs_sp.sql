

CREATE PROCEDURE [dbo].[ALP_qryCSBS_GetExceptions_AllTXErrs_sp]
AS
SELECT T.Transmitter,E.ErrorCode 
FROM ALP_tblCSTransmitterExceptions T
	INNER JOIN ALP_tblCSTransmitterErrorsToBlock E
		ON T.Transmitter = E.Transmitter
ORDER BY T.Transmitter, E.ErrorCode
CREATE PROCEDURE dbo.ALP_qryCSBS_GetExceptions_AllTX_sp
AS
SELECT T.Transmitter 
FROM ALP_tblCSTransmitterExceptions T
ORDER BY T.Transmitter
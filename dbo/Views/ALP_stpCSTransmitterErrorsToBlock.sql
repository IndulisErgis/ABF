


CREATE VIEW [dbo].[ALP_stpCSTransmitterErrorsToBlock]  
AS  
--SELECT Transmitter, ErrorCode, DisabledDate, DisabledBy  
--FROM dbo.ALP_tblCSTransmitterErrorsToBlock  

SELECT TEB.ID, TEB.Transmitter, TEB.ErrorCode, TEB.DisabledDate, TEB.DisabledBy, EC.ErrorMessage
FROM dbo.ALP_tblCSTransmitterErrorsToBlock TEB  inner join 
dbo.ALP_tblCSErrorCodes EC on TEB.ErrorCode=EC.ErrorCode
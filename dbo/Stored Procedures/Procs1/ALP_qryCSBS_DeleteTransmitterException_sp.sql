
        
CREATE Procedure [dbo].[ALP_qryCSBS_DeleteTransmitterException_sp]
	(
	@Transmitter varchar(36),
	@ErrorCode varchar(4)
	)
AS
SET NOCOUNT ON
DELETE FROM  dbo.ALP_tblCSTransmitterErrorsToBlock
WHERE (Transmitter = @Transmitter) AND (ErrorCode = @ErrorCode)

DELETE FROM dbo.ALP_tblCSTransmitterExceptions
WHERE (Transmitter = @Transmitter) AND 
	((SELECT COUNT(*) 
		FROM ALP_tblCSTransmitterErrorsToBlock 
		WHERE Transmitter = @Transmitter) = 0)
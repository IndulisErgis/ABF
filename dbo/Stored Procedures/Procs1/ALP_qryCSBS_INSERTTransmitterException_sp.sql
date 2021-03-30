
CREATE Procedure [dbo].[ALP_qryCSBS_INSERTTransmitterException_sp]
	(
	@Transmitter varchar(36),
	@ErrorCode varchar(4)
	)
AS
SET NOCOUNT ON
IF  NOT EXISTS 
	(SELECT * FROM dbo.ALP_tblCSTransmitterExceptions 
	 WHERE Transmitter = @Transmitter)
   BEGIN
	INSERT INTO dbo.ALP_tblCSTransmitterExceptions
		(Transmitter)
		VALUES
		(@Transmitter)
   END


IF NOT EXISTS 
	(SELECT * FROM dbo.ALP_tblCSTransmitterErrorsToBlock 
	 WHERE (Transmitter = @Transmitter) 
		AND 
	       (ErrorCode = @ErrorCode)
	)
   BEGIN
	INSERT INTO dbo.ALP_tblCSTransmitterErrorsToBlock
		(Transmitter,
		ErrorCode,
		DisabledDate,
		DisabledBy)
		VALUES
		(@Transmitter,
		@ErrorCode,
		GetDate(),
		HOST_NAME() + '\' + SUSER_SNAME())
   END
CREATE      Procedure [dbo].[ALP_qryCSTransmitterErrorsToBlock_Insert_sp]  
 @Transmitter varchar(36),  
 @ErrorCode varchar(4),
 @DisabledDate datetime,
 @DisabledBy varchar(255)
 
AS  

SET NOCOUNT ON  
INSERT INTO ALP_tblCSTransmitterErrorsToBlock ( Transmitter,ErrorCode, DisabledDate,DisabledBy)  
VALUES(@Transmitter, @ErrorCode , @DisabledDate, @DisabledBy)
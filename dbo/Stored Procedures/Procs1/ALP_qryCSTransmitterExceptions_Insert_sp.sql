CREATE      Procedure [dbo].[ALP_qryCSTransmitterExceptions_Insert_sp]  
 @Transmitter varchar(36) 
AS  

SET NOCOUNT ON  
INSERT INTO ALP_tblCSTransmitterExceptions ( Transmitter)  
VALUES(@Transmitter)
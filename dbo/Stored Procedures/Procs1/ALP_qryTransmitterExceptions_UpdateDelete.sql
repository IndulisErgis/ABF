
CREATE PROCEDURE [dbo].[ALP_qryTransmitterExceptions_UpdateDelete]	
@ID int
AS
Delete ALP_tblCSTransmitterErrorsToBlock  where 
ID=@ID
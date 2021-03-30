CREATE FUNCTION dbo.ALP_ufxCSBS_BatchErrorsForTransmitter_FromTMP  
 (  
  @Transmitter varchar(36)  
 )  
RETURNS varchar(2000)  
As  
begin  
DECLARE @AllErrs varchar(2000)  
SELECT  @AllErrs = IsNull(@AllErrs + ' ','')   
   + EC.ErrorCategory + E.ErrorCode  
   + ' ' + CAST(EC.ErrorMessage as char(30))   
 FROM ALP_tmpCSBSComparisonResultsErrors E  
  INNER JOIN ALP_tblCSErrorCodes EC  
  ON E.ErrorCode = EC.ErrorCode  
 WHERE E.Transmitter = @Transmitter  
Return RTrim(@AllErrs)  
end
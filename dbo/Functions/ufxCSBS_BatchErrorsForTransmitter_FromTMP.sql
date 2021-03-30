
CREATE FUNCTION dbo.ufxCSBS_BatchErrorsForTransmitter_FromTMP
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
	FROM tmpCSBSComparisonResultsErrors E
		INNER JOIN tblCSErrorCodes EC
		ON E.ErrorCode = EC.ErrorCode
	WHERE E.Transmitter = @Transmitter
Return RTrim(@AllErrs)
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCSBS_BatchErrorsForTransmitter_FromTMP] TO PUBLIC
    AS [dbo];


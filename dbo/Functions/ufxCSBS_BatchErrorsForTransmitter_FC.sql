
CREATE FUNCTION dbo.ufxCSBS_BatchErrorsForTransmitter_FC
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
	FROM inqCSBS_BatchCompareRpt_SelectedErrors E
		INNER JOIN tblCSErrorCodes EC
		ON E.ErrorCode = EC.ErrorCode
	WHERE E.Transmitter = @Transmitter
Return RTrim(@AllErrs)
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCSBS_BatchErrorsForTransmitter_FC] TO PUBLIC
    AS [dbo];


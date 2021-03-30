
CREATE FUNCTION [dbo].[ufxCSBS_BatchErrorsForTransmitter2]
--EFI# 1454 MAH 08/26/04 - modified to remove reference to
--		view dbo.inqCSBSComparisonResultsErrors
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
	FROM dbo.ALP_tblCSBSComparisonResultsErrors E
		INNER JOIN ALP_tblCSErrorCodes EC
		ON E.ErrorCode = EC.ErrorCode
	WHERE E.Transmitter = @Transmitter
Return RTrim(@AllErrs)
end
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCSBS_BatchErrorsForTransmitter2] TO PUBLIC
    AS [dbo];


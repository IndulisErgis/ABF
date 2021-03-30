

create PROCEDURE dbo.ALP_qryJmSvcTktVerifyGlAcct_sp
--Created 091404 MAH - for EFI# 1245 
(
	@GlAccount pGlAcct,
	@AccountFound int output
)
AS
SET NOCOUNT ON
SET @AccountFound = 0
IF EXISTS (
	SELECT     AcctId
	FROM         tblGlAcctHdr
	WHERE     (AcctId = @GlAccount)
	)
	SET @AccountFound = 1
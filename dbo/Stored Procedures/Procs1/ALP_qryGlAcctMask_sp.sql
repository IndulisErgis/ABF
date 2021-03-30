

Create procedure [dbo].[ALP_qryGlAcctMask_sp]
(
	@CompID pCompID
)
As

SELECT MaskFormat,FillChar
FROM tblGlAcctMask where CompID = @CompID
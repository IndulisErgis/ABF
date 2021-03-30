


CREATE PROCEDURE dbo.ALP_qryJmSvcTktGetGlNumSegs
--EFI# 1245 MAH 091404 ; removed year as input parameter
@gCompId pCompId
As
SET NOCOUNT ON
SELECT tblGlAcctMask.CompId, tblGlAcctMask.CurYear, tblGlAcctMask.NumSegs
FROM tblGlAcctMask
WHERE tblGlAcctMask.CompId = @gCompId
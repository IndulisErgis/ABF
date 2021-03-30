


CREATE PROCEDURE dbo.ALP_qryJmSvcTktGetGlSegs
--EFI# 1245 MAH 09/14/04 - removed Year as parameter
@gCompId pCompId,
--@Year int,
@Seg int
As
SET NOCOUNT ON
SELECT tblGlAcctMask.CompId, tblGlAcctMask.CurYear, tblGlAcctMask.NumSegs, 
	tblGlAcctMaskSegment.Length AS SegLength
FROM tblGlAcctMask, tblGlAcctMaskSegment
WHERE tblGlAcctMaskSegment.Length = @Seg
-- AND tblGlAcctMask.CurYear = @Year
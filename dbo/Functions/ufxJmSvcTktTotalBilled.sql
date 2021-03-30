CREATE FUNCTION [dbo].[ufxJmSvcTktTotalBilled]
--created 12/09/04 MAH
-- Returns total billed for a job ( without taxes, freight, or other )
-- MUST BE CORRECTED/ UPGRADED to TRAV11 - ABPro11 format!  CODE AS BELOW IS NOT CORRECT 09/23/13 MAH
(@TicketID int )
RETURNS pDec
As
BEGIN
declare @TotalTrans pDec
declare @TotalHist pDec
declare @TotalAmt pDec

SET @TotalTrans = 
	(SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])) AS TotalAmt
	FROM tblArTransHeader INNER JOIN ALP_tblArTransHeader A
	ON tblArTransHeader.TransID = A.AlpTransID
	GROUP BY A.AlpJobNum
	HAVING A.AlpJobNum = @TicketID)
SET @TotalHist = 
	(SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])) AS TotalAmt
	FROM tblArHistHeader INNER JOIN ALP_tblArHistHeader H
	ON tblArHistHeader.TransID = H.AlpTransID
	GROUP BY H.AlpJobNum
	HAVING H.AlpJobNum = @TicketID)
SET @TotalAmt = COALESCE(@TotalTrans,0) + COALESCE(@TotalHist,0) 

RETURN @TotalAmt
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxJmSvcTktTotalBilled] TO PUBLIC
    AS [dbo];


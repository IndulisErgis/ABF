CREATE FUNCTION [dbo].[ALP_ufxJmSvcTktTotalBilled]
--created 12/09/04 MAH
-- Returns total billed for a job ( without taxes, freight, or other )
(@TicketID int )
RETURNS pDec
As
BEGIN
declare @TotalTrans pDec
declare @TotalHist pDec
declare @TotalAmt pDec

SET @TotalTrans = 
	(SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])) AS TotalAmt
	FROM ALP_tblArTransHeader_view
	GROUP BY ALP_tblArTransHeader_view.AlpJobNum
	HAVING ALP_tblArTransHeader_view.AlpJobNum = @TicketID)
SET @TotalHist = 
	(SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])) AS TotalAmt
	FROM ALP_tblArHistHeader_view
	GROUP BY ALP_tblArHistHeader_view.AlpJobNum
	HAVING ALP_tblArHistHeader_view.AlpJobNum = @TicketID)
SET @TotalAmt = COALESCE(@TotalTrans,0) + COALESCE(@TotalHist,0) 

RETURN @TotalAmt
END
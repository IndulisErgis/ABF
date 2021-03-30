
CREATE PROCEDURE dbo.ALP_rptJmSvcTktRptInvcTotals_sp
(
@TicketID int
)
AS
SET NOCOUNT ON
SELECT
TotalInvc = Sum([TaxSubTotal]+[NonTaxSubTotal]+[SalesTax]), 
TotalAmt = Sum([TaxSubTotal]+[NonTaxSubTotal]), 
TotalTaxes = Sum(SalesTax),
InvcNum, 
AlpJobNum
FROM tblArHistHeader 
left outer JOIN
         ALP_tblArHistHeader ON tblArHistHeader.PostRun = ALP_tblArHistHeader.AlpPostRun and
         tblArHistHeader.TransId = ALP_tblArHistHeader.AlpTransId
GROUP BY ALP_tblArHistHeader.AlpJobNum, InvcNum
HAVING ALP_tblArHistHeader.AlpJobNum= @TicketID
UNION 
SELECT
TotalInvc = Sum([TaxSubTotal]+[NonTaxSubTotal]+[SalesTax]), 
TotalAmt = Sum([TaxSubTotal]+[NonTaxSubTotal]), 
TotalTaxes = Sum(SalesTax), 
InvcNum, 
ALpJobNum
FROM tblArTransHeader left outer join 
 ALP_tblArTransHeader ON tblArTransHeader.TransId = ALP_tblArTransHeader.AlpTransId
GROUP BY ALP_tblArTransHeader.AlpJobNum,InvcNum
HAVING ALP_tblArTransHeader.AlpJobNum=@TicketID
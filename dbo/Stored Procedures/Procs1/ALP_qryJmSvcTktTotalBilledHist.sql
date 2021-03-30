
CREATE PROCEDURE dbo.ALP_qryJmSvcTktTotalBilledHist
--EFI# ???? MAH 03/22/06 - multiply the SalesTax by Transaction type
@ID int
As
SET NOCOUNT ON
SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])+[SalesTax]+([Freight]*[TransType])+([Misc]*[TransType])) AS TotalHist, 
	Sum([TaxSubTotal]*[TransType]+[NonTaxSubTotal]*[TransType]) AS TotalAmt, Sum((ALP_tblArHistHeader_view.SalesTax)*[TransType]) AS TotalTaxes, 
	Sum([Freight]*[TransTYpe]+[Misc]*[TransType]) AS TotalOther
FROM ALP_tblArHistHeader_view
GROUP BY ALP_tblArHistHeader_view.AlpJobNum
HAVING ALP_tblArHistHeader_view.AlpJobNum = @ID

CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktTotalBilledTrans]
--EFI# ???? MAH 03/22/06 - multiply the SalesTax by Transaction type
@ID int
As
SET NOCOUNT ON
SELECT Sum(([TaxSubTotal]*[TransType])+([NonTaxSubTotal]*[TransType])
			--04/15/15 mah - multiply SalesTax by TransType
			--+ [SalesTax]
			+ ([SalesTax] *[TransType])
			--04/15/15 mah - added tax adjamt to total 
			+ (ALP_tblArTransHeader_view.TaxAmtAdj *[TransType])
			+([Freight]*[TransType])+([Misc]*[TransType])) AS TotalTrans, 
		Sum([TaxSubTotal]*[TransType]+[NonTaxSubTotal]*[transtype]) AS TotalAmt, 
		--mah 04/15/15 - corrected sales tax displayed, to consider TaxAdjAmt
		--Sum(ALP_tblArTransHeader_view.SalesTax *[TransType]) AS TotalTaxes,
		Sum((ALP_tblArTransHeader_view.SalesTax *[TransType]) + (ALP_tblArTransHeader_view.TaxAmtAdj *[TransType])) AS TotalTaxes ,
		Sum([Freight]*[TransType]+[Misc]*[TransType]) AS TotalOther
FROM ALP_tblArTransHeader_view
GROUP BY ALP_tblArTransHeader_view.AlpJobNum
HAVING ALP_tblArTransHeader_view.AlpJobNum = @ID
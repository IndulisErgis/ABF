
CREATE PROCEDURE dbo.ALP_qryJmUpdateTransTax
@ID int
As
SET NOCOUNT ON
SELECT ALP_tblArTransHeader_view.TransId, ALP_tblArTransHeader_view.TaxGrpID, ALP_tblArTransHeader_view.TaxableYN, ALP_tblArTransHeader_view.TaxClassMisc, 
	ALP_tblArTransHeader_view.TaxSubtotal, ALP_tblArTransHeader_view.NonTaxSubtotal, ALP_tblArTransHeader_view.SalesTax, ALP_tblArTransHeader_view.TaxSubtotalFgn, 
	ALP_tblArTransHeader_view.NonTaxSubtotalFgn, ALP_tblArTransHeader_view.SalesTaxFgn, ALP_tblArTransHeader_view.TaxAmtAdj, ALP_tblArTransHeader_view.TaxAmtAdjFgn
FROM ALP_tblArTransHeader_view
WHERE ALP_tblArTransHeader_view.TransId = @ID
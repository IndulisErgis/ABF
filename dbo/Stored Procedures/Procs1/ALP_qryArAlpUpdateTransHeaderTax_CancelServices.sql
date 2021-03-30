
CREATE Procedure dbo.ALP_qryArAlpUpdateTransHeaderTax_CancelServices
@TransId pTransId,
@TaxSubTotal pdec,
@NonTaxSubTotal pdec,
@SalesTax pdec,
@TaxSubTotalFgn pdec,
@NonTaxSubTotalFgn pdec,
@SalesTaxFgn pdec
AS
SET NOCOUNT ON
UPDATE tblArTransHeader
SET tblArTransHeader.TaxSubTotal = @TaxSubTotal, tblArTransHeader.NonTaxSubTotal = @NonTaxSubTotal, tblArTransHeader.SalesTax = @SalesTax,
	 tblArTransHeader.TaxSubTotalFgn = @TaxSubTotalFgn, tblArTransHeader.NonTaxSubTotalFgn = @NonTaxSubTotalFgn, tblArTransHeader.SalesTaxFgn = @SalesTaxFgn
WHERE tblArTransHeader.TransId=@TransID
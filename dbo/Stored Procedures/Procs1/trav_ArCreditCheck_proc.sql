
CREATE PROCEDURE dbo.trav_ArCreditCheck_proc
	@CustId pCustId
	
AS

SET NOCOUNT ON

BEGIN TRY
	
	DECLARE @PmtAmt pDecimal, @Limit pDecimal, @Open pDecimal, @Tran pDecimal, @Avail pDecimal
	
	SELECT @Limit = COALESCE(CreditLimit, 0)
		FROM dbo.tblArCust (NOLOCK)
		WHERE CustId = @CustID
		
	SELECT @Limit = ISNULL(@Limit, 0)

	SELECT @Open = COALESCE(SUM(SIGN(RecType) * AmtFgn), 0)
		FROM dbo.tblArOpenInvoice (NOLOCK)
		WHERE CustId = @CustID AND [Status] <> 4

	SELECT @Tran = COALESCE(SUM(SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn + FreightFgn + SalesTaxFgn + MiscFgn)), 0)
		FROM dbo.tblArTransHeader (NOLOCK)
		WHERE CustId = @CustID AND VoidYn = 0

	IF (SELECT COUNT(*) FROM dbo.tblSmApp_Installed WHERE AppId = 'SO') > 0 
	BEGIN
		SELECT @Tran = @Tran + COALESCE(SUM(SIGN(TransType) * (TaxableSalesFgn + NonTaxableSalesFgn + FreightFgn + SalesTaxFgn + TaxAmtAdjFgn + MiscFgn)), 0)
			FROM dbo.tblSoTransHeader (NOLOCK)
			WHERE CustId = @CustID AND TransType <> 2 AND VoidYn = 0
	END

	IF (SELECT COUNT(*) FROM dbo.tblSmApp_Installed WHERE AppId = 'SD') > 0 
	BEGIN
		SELECT @Tran = @Tran +COALESCE(SUM(SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn +  SalesTaxFgn +TaxAmtAdjFgn)), 0)
		FROM dbo.tblSvInvoiceHeader (NOLOCK)
		WHERE CustID = @CustId AND VoidYN = 0
	END	
	
	--PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=11931
	SELECT @PmtAmt = COALESCE(SUM(PmtAmt), 0)
		FROM dbo.tblArCashRcptHeader (NOLOCK)
		WHERE CustId = @CustId
	
	SELECT @Tran = @Tran - @PmtAmt

	SELECT @Avail = @Limit - @Open - @Tran
	
	SELECT @Limit AS CreditLimit, @Open AS OpenBal,	@Tran AS TransBal,	@Avail AS AvailBal
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCheck_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCreditCheck_proc';


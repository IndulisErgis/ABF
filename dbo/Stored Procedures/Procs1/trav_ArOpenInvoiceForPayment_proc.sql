CREATE PROCEDURE [dbo].[trav_ArOpenInvoiceForPayment_proc]
	@CustId pCustID
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT  O.CustId AS CustID
				, O.InvcNum AS InvoiceNumber
				, MIN(O.TransDate) AS InvoiceDate
				, MIN(DiscDueDate) AS DiscountDueDate
				, ((SIGN(O.RecType) *O.Amt) -  ISNULL(SUM(T.PmtAmt),0)) AS NetDue
				, ((SIGN(O.RecType) *O.AmtFgn) -  ISNULL(SUM(T.PmtAmt), 0)) AS NetDueFgn
				, SIGN(O.RecType) * O.Amt AS ActualAmountDue
				, SIGN(O.RecType) * O.AmtFgn AS ActualAmountDueFgn
				, ISNULL(SIGN(O.RecType) * O.DiscAmt, 0) AS DiscountAllowed
				, ISNULL(SIGN(O.RecType) * O.DiscAmtFgn, 0) AS DiscountAllowedFgn
				--, ISNULL(SUM(T.PmtAmt), 0) AS PaymentAmount
				, O.[Status]
		FROM dbo.[tblArOpenInvoice] O

		LEFT JOIN (	SELECT H.CustId, D.PmtAmt, D.InvcNum
					FROM dbo.[tblArCashRcptHeader] H
					INNER JOIN dbo.[tblArCashRcptDetail] D ON H.RcptHeaderID = D.RcptHeaderID AND D.InvcType = 1) T

		ON O.InvcNum = T.InvcNum AND O.CustId = T.CustId
		WHERE O.CustId = @CustId AND O.[Status] <> 4 AND O.RecType <> 5
		GROUP BY O.CustId,  O.[Status], O.InvcNum, O.Amt, O.AmtFgn, O.DiscAmt, O.DiscAmtFgn, O.RecType, O.TransDate
		HAVING ((SIGN(O.RecType) *O.Amt) -  ISNULL(SUM(T.PmtAmt),0)) > 0
		ORDER BY O.TransDate ASC

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19107.3183', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArOpenInvoiceForPayment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19107', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArOpenInvoiceForPayment_proc';


CREATE PROCEDURE [dbo].[trav_TpOpenInvoiceForPayment_proc]
	@CustId pCustID
AS
SET NOCOUNT ON
BEGIN TRY

SELECT I.CustId, I.InvoiceNumber, I.InvoiceDate, I.DiscountDueDate, I.NetDue, I.NetDueFgn, I.ActualAmountDue, I.ActualAmountDueFgn, I.DiscountAllowed, I.DiscountAllowedFgn, I.[Status], I.PONumber
 FROM (SELECT  O.CustId AS CustID
				, O.InvcNum AS InvoiceNumber
				, MIN(O.TransDate) AS InvoiceDate
				, MIN(DiscDueDate) AS DiscountDueDate				
				, (SUM(SIGN(O.RecType) *O.Amt) - (ISNULL((T.PmtAmt),0) + ISNULL((T.Disc),0))) AS NetDue
				, (SUM(SIGN(O.RecType) *O.AmtFgn) -  (ISNULL((T.PmtAmt),0) + ISNULL((T.Disc),0))) AS NetDueFgn
				, SUM(SIGN(O.RecType) * O.Amt) AS ActualAmountDue
				, SUM(SIGN(O.RecType) * O.AmtFgn) AS ActualAmountDueFgn
				, ISNULL(SUM(SIGN(O.RecType) * O.DiscAmt), 0) AS DiscountAllowed
				, ISNULL(SUM(SIGN(O.RecType) * O.DiscAmtFgn), 0) AS DiscountAllowedFgn
				--, ISNULL(SUM(T.PmtAmt), 0) AS PaymentAmount
				, O.[Status]
				, MAX(O.CustPONum) AS PONumber
		FROM dbo.[tblArOpenInvoice] O

		LEFT JOIN (	SELECT H.CustId, SUM(D.PmtAmt) AS PmtAmt, SUM(D.[Difference]) AS Disc, D.InvcNum
					FROM dbo.[tblArCashRcptHeader] H
					INNER JOIN dbo.[tblArCashRcptDetail] D ON H.RcptHeaderID = D.RcptHeaderID AND D.InvcType = 1
					GROUP BY D.InvcNum, H.CustId) T

		ON O.CustId = T.CustId AND O.InvcNum = T.InvcNum
		WHERE O.CustId = @CustId AND O.[Status] <> 4 AND O.RecType <> 5
		GROUP BY O.InvcNum, O.CustId,  O.[Status], T.PmtAmt, T.Disc) I
		WHERE I.NetDue != 0
		ORDER BY I.InvoiceDate ASC

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpOpenInvoiceForPayment_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpOpenInvoiceForPayment_proc';


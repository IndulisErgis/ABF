
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_Customer_proc
AS
--PET:http://webfront:801/view.php?id=237482

SET NOCOUNT ON
BEGIN TRY

	DECLARE @WrkStnDate datetime

	--Retrieve global values
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'

	IF @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--list of customers for balance aging 
	CREATE TABLE #CustomerList (CustID pCustId) 

	--work copy of customer values for processing
	CREATE TABLE #CustInfo
	(
		CustId pCustId,
		MaxPaymentDate datetime,
		CurrentBalance pDecimal,
		LastPaymentDate datetime,
		LastPaymentAmount pDecimal,
		LastPaymentNumber pCheckNum
	)	


	--update balance forward customer balances with prepayment values
	UPDATE dbo.tblArCust 
		SET UnpaidFinch = UnpaidFinch - t.AmountAgingPd1
		, BalAge4 = BalAge4 - (t.AmountAgingPd0 + t.AmountAgingPd2)
		, BalAge3 = BalAge3 - t.AmountAgingPd3
		, BalAge2 = BalAge2 - t.AmountAgingPd4
		, BalAge1 = BalAge1 - t.AmountAgingPd5
		, CurAmtDue = CurAmtDue - t.AmountAgingPd6
	FROM dbo.tblArCust 
	INNER JOIN (
		SELECT h.CustID
		, SUM(CASE WHEN h.AgingPd = 0 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd0
		, SUM(CASE WHEN h.AgingPd = 1 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd1 
		, SUM(CASE WHEN h.AgingPd = 2 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd2
		, SUM(CASE WHEN h.AgingPd = 3 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd3
		, SUM(CASE WHEN h.AgingPd = 4 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd4
		, SUM(CASE WHEN h.AgingPd = 5 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd5
		, SUM(CASE WHEN h.AgingPd = 6 THEN d.PmtAmtFgn + d.DifferenceFgn ELSE 0 END) AS AmountAgingPd6
		FROM dbo.tblArCashRcptHeader h 
		INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
		INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
		INNER JOIN dbo.tblArCust c on h.CustId = c.CustId
		WHERE h.CustId IS NOT NULL AND c.AcctType = 1 --Balance Forward		
		GROUP BY h.CustID) t
	ON dbo.tblArCust.CustId = t.CustId
	WHERE dbo.tblArCust.AcctType = 1 --Balance Forward


	--build a list of customer to be aged (transactions, prepayments and Credit Card Customers)
	INSERT INTO #CustomerList (CustId)
		SELECT t.CustId 
		FROM (
			SELECT h.CustId 
				FROM dbo.tblArCashRcptHeader h 
				INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
			UNION
			SELECT p.CustId
				FROM dbo.tblArPmtMethod p 
				INNER JOIN dbo.tblArCashRcptHeader h on p.PmtMethodId = h.PmtMethodId
				INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
				WHERE (p.PmtType = 3 OR p.PmtType = 7) AND p.CustId IS NOT NULL 
		) t 
		WHERE t.CustId IS NOT NULL
		GROUP BY t.CustId


	--age customer balances
	EXEC dbo.trav_ArAgeCustomer_proc


	--capture current information for customers being updated
	INSERT INTO #CustInfo (CustId, MaxPaymentDate, CurrentBalance
		, LastPaymentDate, LastPaymentAmount, LastPaymentNumber)
	SELECT c.CustId, t.MaxPaymentDate
		, (c.CurAmtDue + c.BalAge1 + c.BalAge2 + c.BalAge3 + c.BalAge4 - c.UnapplCredit)
		, c.LastPayDate, c.LastPayAmt, c.LastPayCheckNum
	FROM dbo.tblArCust c
	INNER JOIN (Select h.CustId, MAX(h.PmtDate) MaxPaymentDate
		FROM dbo.tblArCashRcptHeader h 
		INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
		GROUP BY h.CustId) t
	on c.CustId = t.CustId

	
	--update the customer values based upon the processed payments
	UPDATE #CustInfo
		SET LastPaymentDate = h.PmtDate
		, LastPaymentAmount = h.PmtAmt --header.PmtAmt is trans currency
		, LastPaymentNumber = h.CheckNum
	FROM #CustInfo
	INNER JOIN dbo.tblArCashRcptHeader h on #CustInfo.CustId = h.CustId AND #CustInfo.MaxPaymentDate = h.PmtDate
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	WHERE (#CustInfo.LastPaymentDate <= h.PmtDate OR #CustInfo.LastPaymentDate IS NULL)


	--apply the changes to the customer
	UPDATE dbo.tblArCust
		Set dbo.tblARCust.LastPayDate = t.LastPaymentDate
			, dbo.tblArCust.LastPayAmt = t.LastPaymentAmount
			, dbo.tblArCust.LastPayCheckNum = t.LastPaymentNumber
			, dbo.tblArCust.HighBal = CASE WHEN isnull(dbo.tblArCust.HighBal, 0) < t.CurrentBalance 
				THEN t.CurrentBalance 
				ELSE dbo.tblArCust.HighBal END 
	FROM #CustInfo t
	WHERE dbo.tblArCust.CustId = t.CustId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_Customer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_Customer_proc';


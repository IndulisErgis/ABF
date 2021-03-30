
CREATE PROCEDURE dbo.trav_PsTransPost_Customer_proc
AS
SET NOCOUNT ON
BEGIN TRY
	--Skip foreign customer for now
	--TODO, Layaway
	--TODO, RewardRedemption
	--list of customers for balance aging 
	CREATE TABLE #CustomerList (CustID pCustId) 

	--work copy of customer values for processing
	CREATE TABLE #CustInfo
	(
		CustId pCustId NOT NULL,
		MaxInvoiceNumber pInvoiceNum NULL,
		MaxInvoiceDate datetime NULL,
		MinInvoiceDate datetime NULL,
		CurrentBalance pCurrDecimal NOT NULL,
		LastInvoiceNumber pInvoiceNum NULL,
		LastInvoiceDate datetime NULL,
		LastInvoiceAmount pDecimal NULL,
		LastPaymentDate datetime NULL,
		LastPaymentAmount pDecimal NULL,
		LastPaymentNumber pCheckNum NULL,
		MaxPaymentDate datetime NULL,
	)	

	--update balance forward customer balances with transaction values
	--	(Add invoices to the Current amount due and credit memos to the unapplied credit)
	--	(Note: customer aging will redistribute the unapplied credit)
	UPDATE dbo.tblArCust 
		SET CurAmtDue = CurAmtDue + t.InvoiceNetDue
		, UnapplCredit = UnapplCredit + t.CreditNetDue
	FROM dbo.tblArCust 
	INNER JOIN (SELECT h.BillToID
		, SUM(CASE WHEN h.TransType > 0 THEN t.NetDue ELSE 0 END) AS InvoiceNetDue
		, SUM(CASE WHEN h.TransType > 0 THEN 0 ELSE t.NetDue END) AS CreditNetDue
		FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID
			INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId 
		WHERE h.VoidDate IS NULL
		GROUP BY h.BillToID) t
	ON dbo.tblArCust.CustId = t.BillToID
	WHERE dbo.tblArCust.AcctType = 1 --Balance Forward

	--Misc payment
	UPDATE dbo.tblArCust 
		SET UnapplCredit = UnapplCredit + t.PaymentTotal
	FROM dbo.tblArCust 
	INNER JOIN (SELECT p.CustID
		, SUM(p.Amount) AS PaymentTotal
		FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID
			INNER JOIN dbo.tblArCust c ON p.CustID = c.CustId 
		WHERE p.HeaderID IS NULL AND p.VoidDate IS NULL
		GROUP BY p.CustID) t
	ON dbo.tblArCust.CustId = t.CustID
	WHERE dbo.tblArCust.AcctType = 1 --Balance Forward

	--build a list of customer to be aged from transactions and misc payments
	INSERT INTO #CustomerList (CustId)
	SELECT BillToID FROM
	(SELECT h.BillToID 
	FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
		INNER JOIN dbo.tblArCust c ON h.BillToID = c.CustId
	WHERE h.VoidDate IS NULL
	UNION ALL
	SELECT p.CustID
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblArCust c ON p.CustID = c.CustId 
	WHERE p.HeaderID IS NULL AND p.VoidDate IS NULL) h
	GROUP BY BillToID

	--age customer balances
	EXEC dbo.trav_ArAgeCustomer_proc

	--capture current information for customers being updated
	INSERT INTO #CustInfo (CustId, MaxInvoiceDate, MinInvoiceDate, CurrentBalance, LastInvoiceNumber, LastInvoiceDate, 
		LastInvoiceAmount, LastPaymentDate, LastPaymentAmount, LastPaymentNumber, MaxPaymentDate)
	SELECT c.CustId, i.MaxInvoiceDate, i.MinInvoiceDate, (c.CurAmtDue + c.BalAge1 + c.BalAge2 + c.BalAge3 + c.BalAge4 - c.UnapplCredit), 
		c.LastSaleInvc, c.LastSaleDate, c.LastSaleAmt, c.LastPayDate, c.LastPayAmt, c.LastPayCheckNum, p.MaxPaymentDate
	FROM #CustomerList t INNER JOIN dbo.tblArCust c ON t.CustID = c.CustId
		LEFT JOIN (SELECT h.BillToID, MAX(CASE WHEN h.TransType > 0 THEN h.TransDate ELSE NULL END) MaxInvoiceDate, 
			MIN(CASE WHEN h.TransType > 0 THEN h.TransDate ELSE NULL END) MinInvoiceDate
			FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID
			WHERE h.BillToID IS NOT NULL AND h.VoidDate IS NULL
			GROUP BY h.BillToID) i ON c.CustId = i.BillToID
		LEFT JOIN (SELECT p.CustID, MAX(p.PmtDate) MaxPaymentDate
			FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID
			WHERE p.CustID IS NOT NULL AND p.VoidDate IS NULL
			GROUP BY p.CustID) p ON c.CustId = p.CustID

	--isolate the max invoice number for the most recent date being posted
	UPDATE #CustInfo Set MaxInvoiceNumber = t.MaxInvoiceNumber
	FROM (SELECT h.BillToID, h.TransDate, MAX(t.InvoiceNum) MaxInvoiceNumber
		FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID
		WHERE h.BillToID IS NOT NULL AND h.TransType = 1 AND h.VoidDate IS NULL
		GROUP BY h.BillToID, h.TransDate) t
	WHERE #CustInfo.CustId = t.BillToID AND #CustInfo.MaxInvoiceDate = t.TransDate

	--update the customer values based upon the processed transactions
	UPDATE #CustInfo
		SET LastInvoiceNumber = MaxInvoiceNumber 
		, LastInvoiceDate = MaxInvoiceDate
		, LastInvoiceAmount = h.InvoiceAmount
	FROM #CustInfo 
	INNER JOIN (SELECT h.BillToID, h.TransDate, t.InvoiceNum, d.InvoiceAmount
		FROM #PsTransList t INNER JOIN dbo.tblPsTransHeader h ON t.ID = h.ID 
			INNER JOIN (SELECT HeaderID, SUM(SIGN(LineType) * ExtPrice) InvoiceAmount FROM dbo.tblPsTransDetail WHERE LineType <> -1 AND  LineType <> -4 GROUP BY HeaderID) d ON h.ID = d.HeaderID
		WHERE h.BillToID IS NOT NULL AND h.TransType = 1 AND h.VoidDate IS NULL	AND d.InvoiceAmount > 0
		) h ON #CustInfo.CustId = h.BillToID AND #CustInfo.MaxInvoiceNumber = h.InvoiceNum AND #CustInfo.MaxInvoiceDate = h.TransDate
	WHERE NOT(MaxInvoiceNumber IS NULL) AND (#CustInfo.LastInvoiceDate IS NULL OR #CustInfo.LastInvoiceDate <= h.TransDate)

	--apply the changes to the customer
	UPDATE dbo.tblArCust
		SET dbo.tblArCust.LastSaleInvc = t.LastInvoiceNumber, dbo.tblArCust.LastSaleDate = t.LastInvoiceDate, 
			dbo.tblArCust.LastSaleAmt = t.LastInvoiceAmount, 
			dbo.tblArCust.HighBal = CASE WHEN isnull(dbo.tblArCust.HighBal, 0) < t.CurrentBalance THEN t.CurrentBalance ELSE dbo.tblArCust.HighBal END, 
			dbo.tblArCust.FirstSaleDate = CASE WHEN dbo.tblArCust.FirstSaleDate IS NULL OR dbo.tblArCust.FirstSaleDate > t.MinInvoiceDate 
				THEN t.MinInvoiceDate ELSE dbo.tblArCust.FirstSaleDate END
	FROM #CustInfo t
	WHERE dbo.tblArCust.CustId = t.CustId
	
	--update the customer values based upon the processed payments
	--Misc payment
	UPDATE #CustInfo
		SET LastPaymentDate = p.PmtDate, LastPaymentAmount = p.Amount, LastPaymentNumber = p.CheckNum
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN #CustInfo ON p.CustId = #CustInfo.CustId AND p.PmtDate = #CustInfo.MaxPaymentDate
	WHERE p.HeaderID IS NULL AND p.VoidDate IS NULL AND (#CustInfo.LastPaymentDate <= p.PmtDate OR #CustInfo.LastPaymentDate IS NULL)

	--Transaction Payment
	UPDATE #CustInfo
		SET LastPaymentDate = p.PmtDate, LastPaymentAmount = p.Amount, LastPaymentNumber = p.CheckNum
	FROM #PsPaymentList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.ID 
		INNER JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID 
		INNER JOIN #CustInfo ON h.BillToID = #CustInfo.CustId AND p.PmtDate = #CustInfo.MaxPaymentDate
	WHERE p.VoidDate IS NULL AND (#CustInfo.LastPaymentDate <= p.PmtDate OR #CustInfo.LastPaymentDate IS NULL)

	--apply the changes to the customer
	UPDATE dbo.tblArCust
		SET dbo.tblARCust.LastPayDate = t.LastPaymentDate, dbo.tblArCust.LastPayAmt = t.LastPaymentAmount, 
			dbo.tblArCust.LastPayCheckNum = t.LastPaymentNumber, 
			dbo.tblArCust.HighBal = CASE WHEN isnull(dbo.tblArCust.HighBal, 0) < t.CurrentBalance THEN t.CurrentBalance ELSE dbo.tblArCust.HighBal END 
	FROM #CustInfo t
	WHERE dbo.tblArCust.CustId = t.CustId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_Customer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransPost_Customer_proc';


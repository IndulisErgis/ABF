
CREATE PROCEDURE dbo.trav_PcBillingPost_Customer_proc
AS
SET NOCOUNT ON
BEGIN TRY
	--list of customers for balance aging 
	CREATE TABLE #CustomerList (CustID pCustId) 

	--work copy of customer values for processing
	CREATE TABLE #CustInfo
	(
		CustId pCustId,
		MaxInvoiceNumber pInvoiceNum,
		MaxInvoiceDate datetime,
		MinInvoiceDate datetime,
		CurrentBalance pDecimal,
		LastInvoiceNumber pInvoiceNum,
		LastInvoiceDate datetime,
		LastInvoiceAmount pDecimal,
	)	

	--update balance forward customer balances with transaction values
	--	(Add invoices to the Current amount due and credit memos to the unapplied credit)
	--	(Note: customer aging will redistribute the unapplied credit)
	UPDATE dbo.tblArCust 
		SET CurAmtDue = CurAmtDue + t.InvoiceTotal
		, UnapplCredit = UnapplCredit + t.CreditMemoTotal
	FROM dbo.tblArCust 
	INNER JOIN (SELECT c.CustId
		, SUM(CASE WHEN h.TransType > 0 THEN h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn ELSE 0 END) AS InvoiceTotal
		, SUM(CASE WHEN h.TransType > 0 THEN 0 ELSE h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn END) AS CreditMemoTotal
		FROM #PostTransList b INNER JOIN dbo.tblPcInvoiceHeader h on b.TransId = h.TransId
			INNER JOIN dbo.tblArCust c on h.CustId = c.CustId
		WHERE h.VoidYn = 0 AND c.AcctType = 1 --Balance Forward
		GROUP BY c.CustId) t
	ON dbo.tblArCust.CustId = t.CustId
	WHERE dbo.tblArCust.AcctType = 1 --Balance Forward

	--build a list of customer to be aged
	INSERT INTO #CustomerList (CustId)
	SELECT h.CustId 
	FROM #PostTransList b INNER JOIN dbo.tblPcInvoiceHeader h on b.TransId = h.TransId
	WHERE h.VoidYn = 0
	GROUP BY h.CustId

	--age customer balances
	EXEC dbo.trav_ArAgeCustomer_proc

	--capture current information for customers being updated
	INSERT INTO #CustInfo (CustId, MaxInvoiceDate, MinInvoiceDate, CurrentBalance
		, LastInvoiceNumber, LastInvoiceDate, LastInvoiceAmount)
	SELECT c.CustId, t.MaxInvoiceDate, t.MinInvoiceDate
		, (c.CurAmtDue + c.BalAge1 + c.BalAge2 + c.BalAge3 + c.BalAge4 - c.UnapplCredit)
		, c.LastSaleInvc, c.LastSaleDate, c.LastSaleAmt
	FROM dbo.tblArCust c INNER JOIN 
		(Select h.CustId, MAX(CASE WHEN h.TransType > 0 THEN h.InvcDate ELSE NULL END) MaxInvoiceDate, 
			MIN(CASE WHEN h.TransType > 0 THEN h.InvcDate ELSE NULL END) MinInvoiceDate
			FROM #PostTransList b INNER JOIN dbo.tblPcInvoiceHeader h on b.TransId = h.TransId
			WHERE h.VoidYn = 0	GROUP BY h.CustId) t
		on c.CustId = t.CustId

	--isolate the max invoice number for the most recent date being posted
	UPDATE #CustInfo Set MaxInvoiceNumber = t.MaxInvoiceNumber
	FROM (SELECT h.CustId, h.InvcDate
		, MAX(ISNULL(h.InvcNum, b.DefaultInvoiceNumber)) MaxInvoiceNumber
		FROM #PostTransList b INNER JOIN dbo.tblPcInvoiceHeader h on b.TransId = h.TransId
		WHERE h.TransType > 0 AND VoidYn = 0
		GROUP BY h.CustId, h.InvcDate) t
	WHERE #CustInfo.CustId = t.CustId AND #CustInfo.MaxInvoiceDate = t.InvcDate

	--update the customer values based upon the processed transactions
	UPDATE #CustInfo
		SET LastInvoiceNumber = MaxInvoiceNumber 
		, LastInvoiceDate = MaxInvoiceDate
		, LastInvoiceAmount = h.InvoiceAmount
	FROM #CustInfo 
	INNER JOIN (SELECT h.CustId, h.InvcDate, ISNULL(h.InvcNum, b.DefaultInvoiceNumber) AS InvcNum
		, (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn) AS InvoiceAmount
		FROM #PostTransList b INNER JOIN dbo.tblPcInvoiceHeader h on b.TransId = h.TransId
		WHERE h.TransType > 0 AND h.VoidYn = 0
			AND (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn) > 0
		) h ON #CustInfo.CustId = h.CustId 
			AND #CustInfo.MaxInvoiceNumber = h.InvcNum
			AND #CustInfo.MaxInvoiceDate = h.InvcDate
	WHERE NOT(MaxInvoiceNumber IS NULL) 
		AND (#CustInfo.LastInvoiceDate IS NULL OR #CustInfo.LastInvoiceDate <= h.InvcDate)

	--apply the changes to the customer
	UPDATE dbo.tblArCust
		Set dbo.tblArCust.LastSaleInvc = t.LastInvoiceNumber
			, dbo.tblArCust.LastSaleDate = t.LastInvoiceDate
			, dbo.tblArCust.LastSaleAmt = t.LastInvoiceAmount
			, dbo.tblArCust.HighBal = CASE WHEN isnull(dbo.tblArCust.HighBal, 0) < t.CurrentBalance 
				THEN t.CurrentBalance 
				ELSE dbo.tblArCust.HighBal END 
			, dbo.tblArCust.FirstSaleDate = CASE WHEN dbo.tblArCust.FirstSaleDate IS NULL OR dbo.tblArCust.FirstSaleDate > t.MinInvoiceDate 
				THEN t.MinInvoiceDate 
				ELSE dbo.tblArCust.FirstSaleDate END
	FROM #CustInfo t
	WHERE dbo.tblArCust.CustId = t.CustId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_Customer_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_Customer_proc';


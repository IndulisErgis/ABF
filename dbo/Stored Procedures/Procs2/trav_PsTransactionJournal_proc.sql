
CREATE PROCEDURE dbo.trav_PsTransactionJournal_proc

AS
BEGIN TRY
	SET NOCOUNT ON

	INSERT INTO #PsTransList(ID, TransID, InvoiceNum) 
	SELECT h.ID, ROW_NUMBER() OVER (ORDER BY h.ID)
		, h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8) 
	FROM #PsHostList t INNER JOIN dbo.tblPsTransHeader h ON t.HostID = h.HostID 
	WHERE Synched = 1 AND h.VoidDate IS NULL AND h.SuspendDate IS NULL 
		AND (h.TransType IN (1, -1) OR (h.TransType = 10 AND h.CompletedDate IS NOT NULL))

	INSERT INTO #PsIncompleteLayawayList(ID) 
	SELECT h.ID 
	FROM #PsHostList t INNER JOIN dbo.tblPsTransHeader h ON t.HostID = h.HostID 
	WHERE Synched = 1 AND h.VoidDate IS NULL AND h.SuspendDate IS NULL 
		AND h.TransType = 10 AND h.CompletedDate IS NULL

	INSERT INTO #PsPaymentList(ID, TransID, PaymentType) 
	SELECT p.ID, ROW_NUMBER() OVER (ORDER BY p.ID), p.PaymentType 
	FROM 
	(
		SELECT p.ID, 0 AS PaymentType 
		FROM #PsHostList t INNER JOIN dbo.tblPsPayment p ON t.HostID = p.HostID 
		WHERE p.HeaderID IS NULL AND p.Synched = 1 AND p.PostedYN = 0
		UNION ALL
		SELECT p.ID, 0 AS PaymentType  
		FROM #PsTransList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID 
		WHERE p.Synched = 1 AND p.PostedYN = 0 
		UNION ALL
		SELECT p.ID, 1 AS PaymentType  
		FROM #PsIncompleteLayawayList t INNER JOIN dbo.tblPsPayment p ON t.ID = p.HeaderID 
		WHERE p.Synched = 1 AND p.PostedYN = 0 
	) p

	--Table (TypeID)
	SELECT 0 AS TypeID
	UNION
	SELECT 1 AS TypeID

	--Table1 (TransHeader)
	SELECT 0 AS TypeID, h.ID AS HeaderID, c.LocID, h.HostID
		, h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8) AS TransID, h.TransType
		, h.CurrencyID, ISNULL(h.BillToID, h.SoldToID) AS BillToID, t.Name AS BillToName, h.SalesRepID, h.TaxGroupID, h.TransDate
		, d.TotalSale AS Subtotal
		, d.TaxTotal AS SalesTax
		, d.PaymentsTotal + d.RoundingAdjustmentTotal AS Payment
		, d.ExtCost AS ExtCost
		, d.ExtPrice AS ExtPrice
		, d.TotalSale + d.TaxTotal + d.PaymentsTotal + d.RoundingAdjustmentTotal AS InvTotal 
	FROM #PsTransList temp 
		INNER JOIN dbo.tblPsTransHeader h ON temp.ID = h.ID 
		LEFT JOIN dbo.tblPsConfig c ON h.HostID = c.HostID 
		LEFT JOIN 
		(
			SELECT HeaderID, Name FROM dbo.tblPsTransContact WHERE [Type] = 1
		) t ON h.ID = t.HeaderID 
		LEFT JOIN 
		(
			SELECT HeaderID
				, SUM(ISNULL(CASE dtl.LineType 
								WHEN 1 THEN dtl.ExtPrice 
								WHEN 3 THEN dtl.ExtPrice 
								WHEN 4 THEN dtl.ExtPrice 
								WHEN -2 THEN dtl.ExtPrice 
								WHEN -3 THEN dtl.ExtPrice 
								ELSE 0 END, 0)) AS TotalSale
				, SUM(ISNULL(CASE dtl.LineType WHEN 2 THEN dtl.ExtPrice ELSE 0 END, 0)) AS TaxTotal
				, SUM(ISNULL(CASE dtl.LineType WHEN -4 THEN dtl.ExtPrice ELSE 0 END, 0)) AS RoundingAdjustmentTotal
				, SUM(ISNULL(CASE dtl.LineType WHEN -1 THEN dtl.ExtPrice ELSE 0 END, 0)) AS PaymentsTotal
				, SUM(ISNULL(CASE dtl.LineType 
								WHEN 1 THEN dtl.ExtCost 
								WHEN 3 THEN dtl.ExtCost 
								WHEN 4 THEN dtl.ExtCost 
								WHEN -2 THEN dtl.ExtCost 
								WHEN -3 THEN dtl.ExtCost 
								ELSE 0 END, 0)) AS ExtCost
				, SUM(ISNULL(CASE dtl.LineType 
								WHEN 1 THEN dtl.ExtPrice 
								WHEN 3 THEN dtl.ExtPrice 
								WHEN 4 THEN dtl.ExtPrice 
								WHEN -2 THEN dtl.ExtPrice 
								WHEN -3 THEN dtl.ExtPrice 
								ELSE 0 END, 0)) AS ExtPrice 
			FROM 
			(
				SELECT LineType, HeaderID
					, SUM(ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * i.ExtCost, 0)) AS ExtCost
					, SUM(ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * d.ExtPrice, 0)) AS ExtPrice 
				FROM dbo.tblPsTransDetail d 
					INNER JOIN #PsTransList temp ON d.HeaderID = temp.ID 
					LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID 
					LEFT JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID 
				GROUP BY LineType, HeaderID
			) dtl GROUP BY HeaderID
		) d ON h.ID = d.HeaderID

	--Table2 (TransDetail)
	--line item
	SELECT d.HeaderID, d.ID AS DetailID, d.LineType
		, CASE d.LineType 
			WHEN 1 THEN 10 
			WHEN 2 THEN 20 
			WHEN 3 THEN 30 
			WHEN 4 THEN 40 
			WHEN 5 THEN 50 
			WHEN -3 THEN 60 
			WHEN -2 THEN 70 
			WHEN -1 THEN 80 
			WHEN -4 THEN 90 
			WHEN -5 THEN 100 
			END AS SortByLineType
		, d.LineSeq, d.EntryNum, d.ItemID, d.Descr
		, d.LocID, d.TaxClass, d.Unit, d.LotNum, d.SerNum, d.Qty
		, ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * i.ExtCost, 0) AS ExtCost
		, ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * d.ExtPrice, 0) AS ExtPrice
		, CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctSales ELSE c.GLAcctSales END AS GLAcctSales
		, CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctCogs ELSE c.GLAcctCogs END AS GLAcctCogs
		, CASE WHEN l.ItemId IS NOT NULL THEN g.GLAcctInv ELSE c.GLAcctInv END AS GLAcctInv 
	FROM dbo.tblPsTransDetail d 
		INNER JOIN #PsTransList temp ON d.HeaderID = temp.ID 
		LEFT JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID 
		LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID 
		LEFT JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId
		LEFT JOIN dbo.tblInGLAcct g ON l.GLAcctCode = g.GLAcctCode
		LEFT JOIN dbo.tblPsConfig o ON h.ConfigID = o.ID		
		LEFT JOIN dbo.tblPsDistCode c ON o.DistCode = c.DistCode
	WHERE d.LineType = 1
	UNION ALL
	-- freight, misc, coupon, discount
	SELECT d.HeaderID, d.ID AS DetailID, d.LineType
		, CASE d.LineType 
			WHEN 1 THEN 10 
			WHEN 2 THEN 20 
			WHEN 3 THEN 30 
			WHEN 4 THEN 40 
			WHEN 5 THEN 50 
			WHEN -3 THEN 60 
			WHEN -2 THEN 70 
			WHEN -1 THEN 80 
			WHEN -4 THEN 90 
			WHEN -5 THEN 100 
			END AS SortByLineType
		, d.LineSeq, d.EntryNum, d.ItemID, d.Descr
		, d.LocID, d.TaxClass, d.Unit, d.LotNum, d.SerNum, d.Qty
		, ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * i.ExtCost, 0) AS ExtCost
		, ISNULL(SIGN(h.TransType) * SIGN(d.LineType) * d.ExtPrice, 0) AS ExtPrice
		, CASE d.LineType 
			WHEN 3 THEN c.GLAcctFreight 
			WHEN 4 THEN c.GLAcctMisc 
			WHEN -2 THEN e.GLAcctCoupon 
			WHEN -3 THEN e.GLAcctDiscount
			WHEN -4 THEN e.GLAcctRounding END AS GLAcctSales
		, NULL AS GLAcctCogs, NULL AS GLAcctInv
	FROM dbo.tblPsTransDetail d 
		INNER JOIN #PsTransList temp ON d.HeaderID = temp.ID 
		LEFT JOIN dbo.tblPsTransHeader h ON d.HeaderID = h.ID 
		LEFT JOIN dbo.tblPsTransDetailIN i ON d.ID = i.DetailID 
		LEFT JOIN dbo.tblPsConfig o ON h.ConfigID = o.ID		
		LEFT JOIN dbo.tblArDistCode c ON o.DistCode = c.DistCode
		LEFT JOIN dbo.tblPsDistCode e ON o.DistCode = e.DistCode
	WHERE d.LineType IN (3, 4, -2, -3)

	--Table3 (Payment)
	SELECT 1 AS TypeID, temp.PaymentType, p.CurrencyID, c.LocID, p.HostID, p.PmtMethodID, p.CustID
		, h.TransIDPrefix + RIGHT(CAST(100000000 + h.TransID AS varchar),8) AS InvoiceNo
		, p.PmtDate, p.CheckNum, p.Amount 
		, CASE WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE m.GLAcctDebit END AS CreditGLAccount --Use the bank gl account for Cash, Check and Direct Debit 	
	FROM #PsPaymentList temp 
		INNER JOIN dbo.tblPsPayment p ON temp.ID = p.ID 
		LEFT JOIN dbo.tblPsConfig c ON p.HostID = c.HostID 
		LEFT JOIN dbo.tblPsTransHeader h ON p.HeaderID = h.ID
		LEFT JOIN dbo.tblArPmtMethod m ON p.PmtMethodID = m.PmtMethodID
		LEFT JOIN dbo.tblSmBankAcct b ON m.BankId = b.BankId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PsTransactionJournal_proc';


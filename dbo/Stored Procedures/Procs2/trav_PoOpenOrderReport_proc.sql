
CREATE PROCEDURE dbo.trav_PoOpenOrderReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@PrintUnpostedReceipt bit = 1,
@PrintPostedReceipt bit = 1,
@PrintUnpostedInvoice bit = 1,
@PrintPostedInvoice bit = 1,
@WorkStationDate datetime = '20090120',
@SortBy tinyint = 0 --0, Transaction No; 1, Vendor ID; 2, Item ID; 3, Requested Date; 4, Status
AS
SET NOCOUNT ON 
BEGIN TRY

	CREATE TABLE #tmpType 
	(
		TransType tinyint NOT NULL, -- 0, New Order; 1, Received/Invoiced
		RecordType tinyint NOT NULL -- 0, Purchase; 1, Tax/Freight/Misc; 2, Prepaid;
	)

	SELECT h.BatchId, h.TransId, h.TransType, h.TransDate, h.ReqShipDate AS ReqShipDateHdr, h.VendorId, h.OrderedBy, 
		h.ReceivedBy, h.ExchRate, h.PrintStatus, h.CurrencyID,
		CASE WHEN @PrintAllInBase = 1 THEN h.MemoTaxable+h.MemoNonTaxable+h.MemoSalesTax+h.MemoFreight+h.MemoMisc
			ELSE h.MemoTaxableFgn+h.MemoNonTaxableFgn+h.MemoSalesTaxFgn+h.MemoFreightFgn+h.MemoMiscFgn END AS MemoTaxFrtMisc, 
		CASE WHEN @PrintAllInBase = 1 THEN h.MemoPrepaid ELSE h.MemoPrepaidFgn END AS MemoPrepaid, 
		d.EntryNum, d.GLAcct, d.QtyOrd, CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn END AS UnitCost, 
		CASE WHEN @PrintAllInBase = 1 THEN  d.ExtCost ELSE d.ExtCostFgn END AS ExtCost, 
		d.ItemId, d.ItemType, d.LocId AS LocIdDtl, d.Descr, d.UnitsBase, 
		d.Units, d.LineStatus, d.GLDesc, ISNULL(d.ReqShipDate,h.ReqShipDate) AS ReqShipDateDtl, 
		COALESCE([RcptQty], 0) AS dRcptQty, COALESCE([RcptExtCost], 0) AS dRcptExtCost, 
		COALESCE([InvcQty], 0) AS dInvcQty, COALESCE([InvcExtCost], 0) AS dInvcExtCost,
		CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN (h.MemoTaxable+h.MemoNonTaxable > 0) THEN 
			(d.ExtCost*((h.MemoSalesTax+h.MemoFreight+h.MemoMisc)/(h.MemoTaxable+h.MemoNonTaxable))) ELSE 0 END 
			ELSE CASE WHEN (h.MemoTaxableFgn+h.MemoNonTaxableFgn > 0) THEN 
			(d.ExtCostFgn*((h.MemoSalesTaxFgn+h.MemoFreightFgn+h.MemoMiscFgn)/(h.MemoTaxableFgn+h.MemoNonTaxableFgn))) ELSE 0 END 
		END AS MemoTaxFrtMiscDtl, 
		CASE WHEN @PrintAllInBase = 1 THEN CASE WHEN (h.MemoTaxable+h.MemoNonTaxable > 0) THEN 
			(d.ExtCost*(h.MemoPrepaid/(h.MemoTaxable+h.MemoNonTaxable))) ELSE 0 END 
			ELSE CASE WHEN (h.MemoTaxableFgn+h.MemoNonTaxableFgn > 0) THEN 
			(d.ExtCostFgn*(h.MemoPrepaidFgn/(h.MemoTaxableFgn+h.MemoNonTaxableFgn))) ELSE 0 END 
		END AS MemoPrepaidDtl 
		,ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate
	INTO #tmpPoOpenOrderRpt
	FROM  #tmpTransDetailList l INNER JOIN dbo.tblPoTransDetail d ON l.TransId = d.TransId AND l.EntryNum = d.EntryNum
		INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId 
		LEFT JOIN (SELECT TransID, EntryNum, SUM(Qty) AS InvcQty,  
			SUM(CASE WHEN @PrintAllInBase = 1 THEN ExtCost ELSE ExtCostFgn END) AS InvcExtCost 
			FROM dbo.tblPoTransInvoice 
			WHERE (@PrintUnpostedInvoice = 1 AND [Status] = 0) OR (@PrintPostedInvoice = 1 AND [Status] = 1)
			GROUP BY TransID, EntryNum) i ON d.TransId = i.TransId AND d.EntryNum = i.EntryNum
		LEFT JOIN (SELECT TransID, EntryNum, SUM(QtyFilled) AS RcptQty,  
			SUM(CASE WHEN @PrintAllInBase = 1 THEN ExtCost ELSE ExtCostFgn END) AS RcptExtCost
			FROM dbo.tblPoTransLotRcpt 
			WHERE (@PrintUnpostedReceipt = 1 AND [Status] = 0) OR (@PrintPostedReceipt = 1 AND [Status] = 1)
			GROUP BY TransID, EntryNum) r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
	WHERE h.TransType <> 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
	ORDER BY h.TransId, d.EntryNum

	SELECT CASE @SortBy 
			WHEN 0 THEN CAST(TransId AS nvarchar) 
			WHEN 1 THEN CAST(VendorId AS nvarchar) 
			WHEN 2 THEN CAST(ItemId AS nvarchar) 
			WHEN 3 THEN CONVERT(nvarchar(8), ReqShipDateDtl , 112) 
			WHEN 4 THEN CAST(TransType  AS nvarchar) END AS SortOrder,
		BatchId, TransId, TransType, TransDate, ReqShipDateHdr, VendorId, OrderedBy, 
		ReceivedBy, ExchRate, PrintStatus, CurrencyID,MemoTaxFrtMisc, MemoPrepaid, 
		EntryNum, GLAcct, QtyOrd, UnitCost, (COALESCE(ExtCost, 0) * SIGN([TransType])) AS ExtCost,
		ItemId, ItemType, LocIdDtl, Descr, UnitsBase, Units, LineStatus, GLDesc, ReqShipDateDtl, dRcptQty, 
		(dRcptExtCost * SIGN([TransType])) AS dRcptExtCost, dInvcQty, (dInvcExtCost * SIGN([TransType])) AS dInvcExtCost, 
		(ExtCost * SIGN([TransType])) AS OrdExtCostGrp01, (dRcptExtCost * SIGN([TransType]))  AS RcptExtCostGrp01,
		(dInvcExtCost * SIGN([TransType])) AS InvcExtCostGrp01, ExpReceiptDate
	FROM #tmpPoOpenOrderRpt 
	ORDER BY TransId, EntryNum

	--Lot
	SELECT r.TransId, r.EntryNum, r.LotNum, 
		SUM(r.QtyFilled) AS QtyRcpt, 
		SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END) AS ExtCostRcpt,
		ISNULL(SUM(CASE WHEN @PrintAllInBase = 1 THEN i.ExtCost ELSE i.ExtCostFgn END),0) AS ExtCostInvc,
		ISNULL(SUM(i.Qty),0) AS QtyInvc
	FROM #tmpTransDetailList l INNER JOIN dbo.tblPoTransLotRcpt r (NOLOCK) ON r.TransId = l.TransId AND r.EntryNum = l.EntryNum 
		INNER JOIN dbo.tblPoTransHeader h ON l.TransId = h.TransId
		LEFT JOIN 
			(SELECT ir.ReceiptId, SUM(i.UnitCost * ir.Qty) ExtCost
			, SUM(i.UnitCostFgn * ir.Qty) ExtCostFgn, SUM(ir.Qty) Qty 
			FROM dbo.tblPoTransInvc_Rcpt ir (NOLOCK) INNER JOIN dbo.tblPoTransInvoice i (NOLOCK) 
			ON ir.InvoiceId = i.InvoiceId GROUP BY ir.ReceiptId) i ON r.ReceiptId = i.ReceiptId
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency)  AND r.LotNum IS NOT NULL AND h.TransType <> 0 
	GROUP BY  r.TransId, r.EntryNum, r.LotNum

	--Ser
	SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, CASE WHEN @PrintAllInBase = 1 THEN s.RcptUnitCost ELSE s.RcptUnitCostFgn END AS RcptUnitCost
	FROM #tmpTransDetailList l INNER JOIN dbo.tblPoTransSer s (NOLOCK) ON s.TransId = l.TransId AND s.EntryNum = l.EntryNum
		INNER JOIN dbo.tblPoTransHeader h ON l.TransId = h.TransId
	WHERE h.TransType <> 0 AND (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 

	--Summary
	INSERT INTO #tmpType (TransType, RecordType) 
	SELECT 0 AS TransType,0 AS RecordType
	UNION ALL
	SELECT 0,1
	UNION ALL
	SELECT 0,2
	UNION ALL
	SELECT 1,0
	UNION ALL
	SELECT 1,1
	UNION ALL
	SELECT 1,2

	--todo, calculation based on order quantity that have not been received.
	SELECT h.TransType, h.RecordType, ISNULL(d.LateShipMent,0) AS LateShipMent, ISNULL(d.Days30,0) AS Days30, 
		ISNULL(d.Days60,0) AS Days60, ISNULL(d.Days90,0) AS Days90, ISNULL(d.Days90Over,0) AS Days90Over, 
		ISNULL(d.NoScheduled,0) AS NoScheduled, 
		ISNULL(d.LateShipMent,0) + ISNULL(d.Days30,0) + ISNULL(d.Days60,0) + ISNULL(d.Days90,0) 
			+ ISNULL(d.Days90Over,0) + ISNULL(d.NoScheduled,0) AS Total 
	FROM #tmpType h 
		LEFT JOIN
		(
			--Purchases
			SELECT CASE TransType WHEN 9 THEN 0 ELSE 1 END TransType, 0 RecordType, 
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) < 0 THEN ExtCost ELSE 0 END) AS LateShipMent,
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 0 AND 30 THEN ExtCost ELSE 0 END) AS Days30, -- 0-30 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 31 AND 60 THEN ExtCost ELSE 0 END) AS Days60, -- 31-60 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 61 AND 90 THEN ExtCost ELSE 0 END) AS Days90, -- 61-90 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) > 90 THEN ExtCost ELSE 0 END) AS Days90Over, -- Over 90 Days
				SUM(CASE WHEN ReqShipDateDtl IS NULL THEN ExtCost ELSE 0 END) AS NoScheduled -- No Scheduled Date
			FROM #tmpPoOpenOrderRpt 
			WHERE TransType > 0 
			GROUP BY CASE TransType WHEN 9 THEN 0 ELSE 1 END
			--Tax/Freight/Misc
			UNION ALL
			SELECT CASE TransType WHEN 9 THEN 0 ELSE 1 END TransType, 1 RecordType, 
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) < 0 THEN MemoTaxFrtMiscDtl ELSE 0 END) AS LateShipMent,
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 0 AND 30 THEN MemoTaxFrtMiscDtl ELSE 0 END) AS Days30, -- 0-30 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 31 AND 60 THEN MemoTaxFrtMiscDtl ELSE 0 END) AS Days60, -- 31-60 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 61 AND 90 THEN MemoTaxFrtMiscDtl ELSE 0 END) AS Days90, -- 61-90 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) > 90 THEN MemoTaxFrtMiscDtl ELSE 0 END) AS Days90Over, -- Over 90 Days
				SUM(CASE WHEN ReqShipDateDtl IS NULL THEN MemoTaxFrtMiscDtl ELSE 0 END) AS NoScheduled -- No Scheduled Date
			FROM #tmpPoOpenOrderRpt 
			WHERE TransType > 0 
			GROUP BY CASE TransType WHEN 9 THEN 0 ELSE 1 END
			--Prepaid
			UNION ALL
			SELECT CASE TransType WHEN 9 THEN 0 ELSE 1 END TransType, 2 RecordType, 
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) < 0 THEN MemoPrepaidDtl ELSE 0 END) AS LateShipMent,
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 0 AND 30 THEN MemoPrepaidDtl ELSE 0 END) AS Days30, -- 0-30 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 31 AND 60 THEN MemoPrepaidDtl ELSE 0 END) AS Days60, -- 31-60 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) BETWEEN 61 AND 90 THEN MemoPrepaidDtl ELSE 0 END) AS Days90, -- 61-90 Days
				SUM(CASE WHEN DATEDIFF(dd,@WorkStationDate,ReqShipDateDtl) > 90 THEN MemoPrepaidDtl ELSE 0 END) AS Days90Over, -- Over 90 Days
				SUM(CASE WHEN ReqShipDateDtl IS NULL THEN MemoPrepaidDtl ELSE 0 END) AS NoScheduled -- No Scheduled Date
			FROM #tmpPoOpenOrderRpt 
			WHERE TransType > 0 
			GROUP BY CASE TransType WHEN 9 THEN 0 ELSE 1 END
		) d ON h.TransType = d.TransType AND h.RecordType = d.RecordType

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoOpenOrderReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoOpenOrderReport_proc';



CREATE PROCEDURE dbo.trav_PoReceivingReport_proc
@SortBy tinyint = 0, --0, Transaction No; 1, Receipt No; 2, Vendor ID; 3, Item ID; 4, Year/GL Period;
@PrintLandedCostDetail bit = 1,
@FiscalYearFrom smallint = 2009,
@FiscalYearThru smallint = 2009,
@FiscalPeriodFrom smallint = 1,
@FiscalPeriodThru smallint = 12
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT CASE @SortBy 
			WHEN 0 THEN CAST(r.TransId AS nvarchar) 
			WHEN 1 THEN CAST(r.ReceiptNum AS nvarchar) 
			WHEN 2 THEN CAST(h.VendorId AS nvarchar) 
			WHEN 3 THEN CAST(d.ItemId AS nvarchar) 
			WHEN 4 THEN CAST(RIGHT('0000' + LTRIM(STR(r.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(r.GlPeriod)), 3) 
				AS nvarchar) END AS GrpId1,
		CASE @SortBy 
			WHEN 0 THEN CAST(h.VendorId AS nvarchar) 
			WHEN 1 THEN CAST(r.TransId AS nvarchar) 
			WHEN 2 THEN CAST(r.TransId AS nvarchar) 
			WHEN 3 THEN CAST(r.TransId AS nvarchar) 
			WHEN 4 THEN CAST(r.TransId AS nvarchar) END AS GrpId2, 
		h.BatchId, v.[Name], h.VendorId, d.ItemId, d.LocId AS LocIdDtl, d.Descr,
		d.Units, r.TransID, r.EntryNum, r.ReceiptNum, r.ReceiptDate, r.GlPeriod, r.FiscalYear,
		r.Qty, r.UnitCost, r.ExtCost * SIGN(h.TransType) AS ExtCost,
		r.ExtCost * SIGN(h.TransType) AS ExtCostRcpt,h.TransType, r.LandedCost,
		CASE WHEN l.TransId IS NULL THEN 0 ELSE 1 END AS LandedCostDetailYn , ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate
	FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorID 
		INNER JOIN dbo.tblPoTransDetail d  ON h.TransId = d.TransID 
		INNER JOIN
			(SELECT p.TransId,r.EntryNum,p.ReceiptNum,p.ReceiptDate,p.GlPeriod,p.FiscalYear, 
				SUM(r.QtyFilled) AS Qty,SUM(r.ExtCost)/SUM(r.QtyFilled) AS UnitCost,
				SUM(r.ExtCost) + SUM(ISNULL(l.Amount, 0)) AS ExtCost,
				SUM(ISNULL(l.Amount, 0)) AS LandedCost
			FROM dbo.tblPoTransReceipt p INNER JOIN dbo.tblPoTransLotRcpt r ON p.TransId = r.TransId AND p.ReceiptNum = r.RcptNum  
				INNER JOIN #tmpTransReceiptList t ON r.ReceiptId = t.ReceiptId
				LEFT JOIN (SELECT ReceiptId, SUM(Amount - PostedAmount) AS Amount 
						FROM dbo.tblPoTransReceiptLandedCost GROUP BY ReceiptId) l ON r.ReceiptId = l.ReceiptId 
			WHERE r.Status = 0 AND p.FiscalYear * 1000 + p.GlPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom 
				AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
			GROUP BY p.TransId,r.EntryNum,p.ReceiptNum,p.ReceiptDate,p.GlPeriod,p.FiscalYear) r 
				ON d.TransId = r.TransId AND d.EntryNum = r.EntryNum
		LEFT JOIN 
			(	SELECT u.TransId,u.EntryNum,u.RcptNum
				FROM #tmpTransReceiptList t INNER JOIN dbo.tblPoTransLotRcpt u ON t.ReceiptId = u.ReceiptId 
					INNER JOIN dbo.tblPoTransReceiptLandedCost v ON u.ReceiptId = v.ReceiptId 
					INNER JOIN dbo.tblPoTransDetailLandedCost l ON v.LCTransSeqNum = l.LCTransSeqNum 
				WHERE (v.Amount - v.PostedAmount) <> 0
				GROUP BY u.TransId,u.EntryNum,u.RcptNum) l 
				ON r.TransId = l.TransId AND r.EntryNum = l.EntryNum AND r.ReceiptNum = l.RcptNum

	IF @PrintLandedCostDetail = 1 
	BEGIN
		SELECT u.TransId,u.EntryNum,u.RcptNum AS ReceiptNum, l.[Description], l.[Level], SUM(v.Amount - v.PostedAmount) AS Amount
		FROM #tmpTransReceiptList t INNER JOIN dbo.tblPoTransLotRcpt u ON t.ReceiptId = u.ReceiptId 
			INNER JOIN dbo.tblPoTransReceiptLandedCost v ON u.ReceiptId = v.ReceiptId 
			INNER JOIN dbo.tblPoTransDetailLandedCost l ON v.LCTransSeqNum = l.LCTransSeqNum 
		WHERE (v.Amount - v.PostedAmount) <> 0
		GROUP BY u.TransId,u.EntryNum,u.RcptNum,l.LCTransSeqNum,l.[Description],l.[Level]
	END
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoReceivingReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoReceivingReport_proc';


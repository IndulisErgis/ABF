
CREATE PROCEDURE dbo.trav_PoAccrualVerificationReport_proc 
@PrintDetail bit,
@GlAcctLandedCostExp pGlAcct,
@FiscalYear smallint,
@UseLandedCost bit
AS
DECLARE
@GlSumAmt Decimal(28,10),
@GlAccrInvAmt Decimal(28,10), 
@GlAccrExpAmt Decimal(28,10), 
@GlAccrApAmt Decimal(28,10), 
@GlLandedCostExpAmt Decimal(28,10), 
@PoAccrInvAmt Decimal(28,10), 
@PoAccrExpAmt Decimal(28,10)

SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #PoAccrualRpt
	(
		TransID nvarchar(8) NOT NULL, 
		BatchId nvarchar(6) NULL, 
		TransType smallint NULL, 
		VendorId nvarchar(10) NULL, 
		VendorName nvarchar(30) NULL, 
		EntryNum smallint NOT NULL, 
		ItemId nvarchar(24) NULL, 
		GLAcctAccrual pGlAcct NULL,
		GLAcctAccrualAp pGlAcct NULL,
		Descr pDescription NULL, 
		Units nvarchar(5) NULL, 
		UnitCost Decimal(28,10) DEFAULT(0) NULL, 
		RcptQty Decimal(28,10) DEFAULT(0) NULL, 
		AccruedQty Decimal(28,10) DEFAULT(0) NULL, 
		AccruedAmt Decimal(28,10) DEFAULT(0) NULL, 
		LandedCost Decimal(28,10) NULL,
		ExpReceiptDate datetime NULL ,
		PRIMARY KEY (TransID, EntryNum) 
	)

	CREATE TABLE #AccrualAccounts
	(
		AcctId pGlAcct NOT NULL, 
		Balance pCurrDecimal NOT NULL,
		AccountType smallint NOT NULL --1, Debit;-1, Credit
		PRIMARY KEY (AcctId, AccountType) 
	)

	INSERT INTO #PoAccrualRpt (TransID,BatchId,TransType,VendorId,EntryNum,ItemId,Descr,Units,LandedCost,VendorName,
		RcptQty,AccruedQty,UnitCost,AccruedAmt,GLAcctAccrual,GLAcctAccrualAp,ExpReceiptDate)
	SELECT h.TransID,h.BatchId,h.TransType,h.VendorId,d.EntryNum,d.ItemId,d.Descr,d.Units,ISNULL(l.PostedAmount,0),v.[Name],
		ISNULL(r.RcptQty,0),ISNULL(r.AccrQty,0),ISNULL(r.UnitCost,0),ISNULL(r.AccruedAmt,0) * SIGN(h.TransType), d.GLAcctAccrual, c.AccrualGLAcct,ISNULL(d.ExpReceiptDate,h.ExpReceiptDate) AS ExpReceiptDate 
	FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransHeader h ON d.TransId = h.TransId 
		INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorId 
		INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode
		LEFT JOIN (SELECT u.TransId,u.EntryNum, SUM(v.Amount) Amount, SUM(v.PostedAmount) PostedAmount
			FROM dbo.tblPoTransLotRcpt u INNER JOIN dbo.tblPoTransReceiptLandedCost v ON u.ReceiptID = v.ReceiptID 
			GROUP BY u.TransId,u.EntryNum) l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum
		LEFT JOIN (SELECT TransID, EntryNum, Sum(QtyFilled) AS RcptQty, Sum(QtyAccRev) AS AccrQty, 
				CASE WHEN Sum(QtyAccRev) = 0 THEN 0 ELSE Sum(QtyAccRev * UnitCost - AccAdjCost)/Sum(QtyAccRev) END AS UnitCost, 
				Sum(QtyAccRev * UnitCost - AccAdjCost) AS AccruedAmt 
			FROM dbo.tblPoTransLotRcpt 
			WHERE Status = 1 
			GROUP BY TransID, EntryNum) r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum
	WHERE h.TransType <> 0
 
	INSERT INTO #AccrualAccounts(AcctId, Balance, AccountType)
	SELECT GLAcctAccrual, 0, 1
	FROM #PoAccrualRpt
	GROUP BY GLAcctAccrual
	UNION
	SELECT GLAcctAccrualAp, 0, -1
	FROM #PoAccrualRpt
	GROUP BY GLAcctAccrualAp
	
 	UPDATE #AccrualAccounts SET Balance = Balance + CASE WHEN AccountType = h.BalType THEN d.Actual ELSE -d.Actual END --Reverse sign of GL account balance if GL account type is not expected account type
	FROM #AccrualAccounts INNER JOIN (SELECT AcctId, SUM(Actual) Actual FROM dbo.tblGlAcctDtl WHERE [Year] = @FiscalYear GROUP BY AcctId) d ON #AccrualAccounts.AcctId = d.AcctId 
		INNER JOIN dbo.tblGlAcctHdr h ON d.AcctId = h.AcctId
	
	UPDATE #AccrualAccounts SET Balance = Balance + Actual * AccountType
	FROM #AccrualAccounts INNER JOIN (SELECT AcctId, SUM(DebitAmt - CreditAmt) Actual FROM dbo.tblGlJrnl WHERE PostedYn = 0 GROUP BY AcctId)  g ON #AccrualAccounts.AcctId = g.AcctId
 
	SELECT a.TransID,a.BatchId,a.TransType,a.VendorId,a.EntryNum,a.ItemId,a.Descr,a.Units,a.LandedCost,a.VendorName,
		a.RcptQty,a.AccruedQty,a.UnitCost,a.AccruedAmt, a.GLAcctAccrual ,ExpReceiptDate
	FROM #PoAccrualRpt a INNER JOIN #tmpTransDetailList t ON a.TransId = t.TransId AND a.EntryNum = t.EntryNum
	WHERE a.AccruedQty > 0 

	--Total
	SELECT p.GlAcct, MAX(g.[Desc]) AS [Desc], MAX(c.Balance) AS GlAccrAmt, ISNULL(SUM(p.AccruedAmt),0) AS PoAccrAmt, MAX(c.Balance) - ISNULL(SUM(p.AccruedAmt),0) AS Variance,
		ISNULL(SUM(p.SelectedPoAccrAmt),0) AS SelectedPoAccrAmt, p.AccountType
	FROM (SELECT a.GLAcctAccrual AS GlAcct, a.AccruedAmt,
		ISNULL(CASE WHEN t.TransId IS NULL THEN 0 ELSE a.AccruedAmt END,0) AS SelectedPoAccrAmt, 1 AS AccountType
	FROM #PoAccrualRpt a LEFT JOIN #tmpTransDetailList t ON a.TransId = t.TransId AND a.EntryNum = t.EntryNum
	UNION ALL
	SELECT a.GLAcctAccrualAp AS GlAcct, a.AccruedAmt,
		ISNULL(CASE WHEN t.TransId IS NULL THEN 0 ELSE a.AccruedAmt END,0) AS SelectedPoAccrAmt, -1 AS AccountType
	FROM #PoAccrualRpt a LEFT JOIN #tmpTransDetailList t ON a.TransId = t.TransId AND a.EntryNum = t.EntryNum) p 
		INNER JOIN #AccrualAccounts c ON p.GlAcct = c.AcctId AND p.AccountType = c.AccountType	
		INNER JOIN dbo.tblGlAcctHdr g ON c.AcctId = g.AcctId 
	GROUP BY p.GlAcct, p.AccountType	

	--Landed Cost
	IF @UseLandedCost = 1 
	BEGIN
		BEGIN
			SELECT @GlSumAmt = SUM(d.Actual) * (-SIGN(MAX(h.BalType))) --GL entry to landed cost account should be a credit entry
			FROM dbo.tblGlAcctDtl d INNER JOIN dbo.tblGlAcctHdr h ON d.AcctId = h.AcctId
			WHERE d.AcctId = @GlAcctLandedCostExp AND d.[Year] = @FiscalYear 

			SET @GlLandedCostExpAmt = ISNULL(@GlSumAmt,0) 

			SELECT @GlSumAmt = SUM(CreditAmt-DebitAmt) --GL entry to landed cost account should be a credit entry
			FROM dbo.tblGlJrnl 
			WHERE PostedYn = 0 AND AcctId = @GlAcctLandedCostExp 

			SET @GlLandedCostExpAmt = @GlLandedCostExpAmt + ISNULL(@GlSumAmt,0) 

			SELECT a.Descr, @GlAcctLandedCostExp AS GlAcctExp, @GlLandedCostExpAmt AS GlTotal, a.Amount, @GlLandedCostExpAmt - a.Amount AS Variance, b.SelectedPoAccrAmt
			FROM (SELECT l.LCTransSeqNum, l.[Description] AS Descr, SUM(v.PostedAmount) Amount
				FROM dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransDetailLandedCost l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
					INNER JOIN dbo.tblPoTransReceiptLandedCost v ON l.LCTransSeqNum = v.LCTransSeqNum 
					INNER JOIN dbo.tblPoTransLotRcpt u ON v.ReceiptId = u.ReceiptId 
				WHERE u.QtyAccRev > 0 AND v.PostedAmount <> 0 
				GROUP BY l.LCTransSeqNum, l.[Description]) a 
			INNER JOIN (SELECT l.LCTransSeqNum, SUM(v.PostedAmount) SelectedPoAccrAmt
			FROM #tmpTransDetailList t 
			    INNER JOIN dbo.tblPoTransHeader h ON h.TransId = t.TransId
			    INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
				INNER JOIN dbo.tblPoTransDetailLandedCost l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
				INNER JOIN dbo.tblPoTransReceiptLandedCost v ON l.LCTransSeqNum = v.LCTransSeqNum 
				INNER JOIN dbo.tblPoTransLotRcpt u ON v.ReceiptId = u.ReceiptId 
			WHERE u.QtyAccRev > 0 AND v.PostedAmount <> 0  AND h.TransType <> 0
			GROUP BY l.LCTransSeqNum) b ON a.LCTransSeqNum = b.LCTransSeqNum

		END

		IF @PrintDetail = 1
		BEGIN
			SELECT u.TransId,u.EntryNum,l.LCDtlSeqNum,l.LCTransSeqNum, l.[Description],l.[Level], SUM(v.PostedAmount) Amount
			FROM #tmpTransDetailList t 
			    INNER JOIN dbo.tblPoTransHeader h ON h.TransId = t.TransId
			    INNER JOIN dbo.tblPoTransDetail d ON t.TransId = d.TransId AND t.EntryNum = d.EntryNum 
				INNER JOIN dbo.tblPoTransDetailLandedCost l ON d.TransId = l.TransId AND d.EntryNum = l.EntryNum 
				INNER JOIN dbo.tblPoTransReceiptLandedCost v ON l.LCTransSeqNum = v.LCTransSeqNum 
				INNER JOIN dbo.tblPoTransLotRcpt u ON v.ReceiptId = u.ReceiptId 
			WHERE h.TransType <> 0
			GROUP BY u.TransId,u.EntryNum,LCDtlSeqNum,l.LCTransSeqNum,l.[Description],l.[Level]
			ORDER BY l.[Level]
		END
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoAccrualVerificationReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoAccrualVerificationReport_proc';


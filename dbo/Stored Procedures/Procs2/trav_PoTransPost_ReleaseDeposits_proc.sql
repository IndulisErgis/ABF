

CREATE PROCEDURE dbo.trav_PoTransPost_ReleaseDeposits_proc
AS
BEGIN TRY

	DECLARE @PrecCurr smallint,@CurrBase pCurrency,@WksDate datetime,
		@PostRun nvarchar(14),@PostAsHeld bit,@wksPeriod smallint, @wksYear smallint	
	DECLARE @MCYn bit

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PostAsHeld = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Held'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @wksPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'WrkStnPeriod'
	SELECT @wksYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'WrkStnYear'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	
	IF @PrecCurr IS NULL OR @CurrBase IS NULL OR @PostRun IS NULL 	OR @PostAsHeld IS NULL	OR @WksDate IS NULL
		 OR @wksPeriod IS NULL OR @wksYear IS NULL 	OR @MCYn IS NULL	
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #TransPostDeposit2
	(	[Counter] int NOT NULL IDENTITY, 	
		VendorID nvarchar(10) NOT NULL, 
		InvcNum nvarchar(15) NOT NULL, 
		GLPeriod smallint NULL DEFAULT(0), 
		FiscalYear smallint NULL DEFAULT(0), 
		PaidStatus tinyint NULL, 
		Ten99InvoiceYN bit NOT NULL, 
		DistCode nvarchar(6) NULL, 
		TermsCode nvarchar(6) NULL, 
		InvoiceDate datetime NULL, 
		NetDueDate datetime NULL, 
		DiscDueDate datetime NULL, 
		DiscAmt decimal(28,10) NULL DEFAULT (0), 
		DiscAmtFgn decimal(28,10) NULL DEFAULT (0), 
		GrossAmtDue decimal(28,10) NULL DEFAULT (0), 
		BaseGrossAmtDue decimal(28,10) NULL , 
		GrossAmtDueFgn decimal(28,10) NULL DEFAULT (0), 
		CheckNum nvarchar(10) NULL, 
		CheckDate datetime NULL, 
		CurrencyID nvarchar(6) NOT NULL, 
		ExchRate pDecimal NULL DEFAULT (1),
		CheckYear smallint NULL DEFAULT(0),
		CheckPeriod smallint NULL DEFAULT(0),
		BankID nvarchar (10) NULL, 
		PmtCurrencyId pCurrency NULL,
		PmtExchRate pDecimal NULL DEFAULT (1),
		Notes nvarchar(max) null,  
		PostRun pPostRun NULL ,
		TransID nvarchar(255) NULL ,	
		GroupID bigint null,
		PRIMARY KEY (Counter) 
	)

	CREATE TABLE #Balance
	(
		ID Bigint,
		TransID pTransID,
		BalanceAmt pDecimal
	)
	CREATE TABLE #completed
	(
		 TransID pTransID Not Null,
		 EntryNum bigint Not Null,
		 QtyOrd pDecimal,
		 LineStatus int 
	 )
	 
	 INSERT INTO #completed (TransID,EntryNum,LineStatus,QtyOrd) 
	 SELECT d.TransID,d.EntryNum,d.LineStatus, d.QtyOrd 
	 FROM #PostTransList i INNER JOIN dbo.tblPoTransDetail d ON i.TransID = d.TransID

	UPDATE #completed SET LineStatus = 1 
	FROM #completed
		INNER JOIN (SELECT r.TransID, r.EntryNum, SUM(r.QtyFilled) RcptQty FROM #PostTransList i 
			INNER JOIN dbo.tblPoTransLotRcpt r ON i.TransID = r.TransID GROUP BY r.TransID, r.EntryNum) t 
			ON #completed.TransID = t.TransID AND #completed.EntryNum = t.EntryNum  
		INNER JOIN (SELECT v.TransID, v.EntryNum, SUM(v.Qty) InvcQty FROM #PostTransList i 
			INNER JOIN dbo.tblPoTransInvoice v ON i.TransID = v.TransID GROUP BY v.TransID, v.EntryNum) v 
			ON #completed.TransID = v.TransID  AND #completed.EntryNum = v.EntryNum
	WHERE #completed.LineStatus = 0 AND t.RcptQty >= QtyOrd AND v.InvcQty = RcptQty


	INSERT INTO #CompletedTransactions (TransId)  

	SELECT TransId	FROM #completed 
	GROUP BY TransId 
	HAVING Min(LineStatus) = 1 

	
	INSERT INTO #Balance(ID,TransID,BalanceAmt)

	SELECT  ID, d.TransID, Amount - AmountApplied AS DepositBalance 		
	FROM dbo.tblPoTransDeposit d
	INNER JOIN #CompletedTransactions c
				ON d.TransID = c.TransID
	WHERE PostRun IS NOT NULL and Amount - AmountApplied > 0
	

	 --invoice 

	 INSERT INTO  #TransPostDeposit2
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue
		, BaseGrossAmtDue
		, DiscAmt, GrossAmtDueFgn, DiscAmtFgn,  CheckNum , CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,TermsCode
		, BankID, PmtCurrencyId, PmtExchRate , Notes, PostRun, TransId,GroupID) 

	SELECT h.VendorId,'Deposit' + d.TransId, 1,0,	i.DistCode,@WksDate,@WksDate,@WksDate
		, CASE WHEN d.ExchRate = 0  THEN 0 ELSE ROUND((b.BalanceAmt/d.ExchRate),@PrecCurr) END
		, d.AmountBase - d.AmountAppliedBase
		, 0,b.BalanceAmt,0,	NULL,NULL,i.CurrencyID,i.ExchRate,@wksPeriod,@wksYear,0,0,i.TermsCode
		, NULL,NULL,1,d.Notes,@PostRun,d.ID, d.InvoiceCounter	
	FROM #CompletedTransactions s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN #Balance b ON b.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter	

	
	--Debit Memo

	 INSERT INTO  #TransPostDeposit2
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue
		, BaseGrossAmtDue
		, DiscAmt, GrossAmtDueFgn, DiscAmtFgn,  CheckNum, CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,TermsCode
		, BankID, PmtCurrencyId, PmtExchRate, Notes, PostRun, TransId,GroupID) 

	SELECT h.VendorId,'Deposit' + d.TransId, CASE WHEN @PostAsHeld = 1 THEN 1 ELSE 0 END,0,	i.DistCode,@WksDate,@WksDate,@WksDate
		, CASE WHEN d.ExchRate = 0  THEN 0 ELSE -1*ROUND((b.BalanceAmt/d.ExchRate),@PrecCurr) END
		, -1 * (d.AmountBase - d.AmountAppliedBase)
		, 0,-1 * b.BalanceAmt,0,	NULL,NULL, i.CurrencyID, i.ExchRate, @wksPeriod, @wksYear, 0, 0, i.TermsCode
		, NULL,NULL,1,D.Notes,@PostRun,d.ID, Null	
	FROM #CompletedTransactions s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN #Balance b ON b.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter	


	--Update OpenInvoice table
	INSERT INTO dbo.tblApOpenInvoice 
		(VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate 
		, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn 
		, CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, PmtCurrencyId 
		, PmtExchRate,  Notes, PostRun, TransId,GroupID) 
	SELECT VendorID, InvcNum, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate 
		, NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn 
		, CheckNum, CheckDate, CurrencyID, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID 
		, PmtCurrencyId, PmtExchRate,  Notes, PostRun, TransId,GroupID
	FROM #TransPostDeposit2

	--Payables Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], TransDate, PostDate
			, Descr, Reference, GlAcct
			, DR
			, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn
			, Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 400, @WksDate, @WksDate
			, SUBSTRING(d.Notes, 1, 30), h.VendorId, dc.PayablesGLAcct
			, d.AmountBase-d.AmountAppliedBase 
			, 0,@wksYear, d.TransID,NULL,0
			, CASE WHEN @MCYN = 1 THEN ah.CurrencyID ELSE @CurrBase END
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN b.BalanceAmt ELSE d.AmountBase - d.AmountAppliedBase END
			, 0
			, d.AmountBase - d.AmountAppliedBase
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN b.BalanceAmt ELSE d.AmountBase - d.AmountAppliedBase END
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM #CompletedTransactions s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter
	INNER JOIN dbo.tblApDistCode dc ON i.DistCode = dc.DistCode
	INNER JOIN #Balance b ON b.ID = d.ID
	INNER JOIN dbo.tblGlAcctHdr ah ON dc.PayablesGLAcct = ah.AcctId

	--Deposit Entry

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], TransDate, PostDate
			, Descr, Reference, GlAcct, DR
			, CR
			, FiscalYear, 	LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn
			, Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 401, @WksDate, @WksDate
			, SUBSTRING(d.Notes, 1, 30), h.VendorId, d.DepositGLAcct,0
			, d.AmountBase - d.AmountAppliedBase
			, @wksYear, d.TransID,NULL,0
			, CASE WHEN @MCYN = 1 THEN ah.CurrencyID ELSE @CurrBase END
			, 0
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN b.BalanceAmt ELSE d.AmountBase - d.AmountAppliedBase END
			, -1*(d.AmountBase - d.AmountAppliedBase)
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN -1*b.BalanceAmt ELSE -1*(d.AmountBase - d.AmountAppliedBase) END
			, CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM #CompletedTransactions s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter
	INNER JOIN #Balance b ON b.ID = d.ID	
	INNER JOIN dbo.tblGlAcctHdr ah ON d.DepositGLAcct = ah.AcctId

	UPDATE dbo.tblPoTransDeposit 
		SET AmountApplied =AmountApplied + b.BalanceAmt,
		AmountAppliedBase =AmountBase		
	FROM #CompletedTransactions s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN #Balance b ON b.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON  i.[Counter] = d.InvoiceCounter
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ReleaseDeposits_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ReleaseDeposits_proc';


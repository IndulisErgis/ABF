

CREATE PROCEDURE dbo.trav_PoTransPost_PostDeposits_proc
AS
BEGIN TRY

	DECLARE @PrecCurr smallint,@CurrBase pCurrency ,@WksDate datetime,@PostRun nvarchar(14),@PostAsHeld bit			
	DECLARE @MCYn bit

	--Retrieve global values
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'	
	SELECT @PostAsHeld = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Held'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'	
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'

	IF @PrecCurr IS NULL OR @CurrBase IS NULL OR @PostRun IS NULL 	OR @PostAsHeld IS NULL
		OR @WksDate IS NULL OR @MCYn IS NULL

	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #TransPostDeposit
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
		PRIMARY KEY (Counter) 
	)
	
	--invoice of deposit.

	INSERT INTO  #TransPostDeposit
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn 
		, CheckNum, CheckDate
		, CurrencyId
		, ExchRate
		, GLPeriod, FiscalYear
		, CheckPeriod, CheckYear
		, TermsCode, BankID, PmtCurrencyId
		, PmtExchRate
		, Notes, PostRun, TransId) 

	SELECT h.VendorId,'Deposit'+ d.TransID,  CASE WHEN  ISNULL(d.BankID,'')<>'' THEN 3 ELSE CASE WHEN @PostAsHeld = 1 THEN 1 ELSE 0 END END
		, 0, h.DistCode, d.DepositDate, d.DepositDate, d.DepositDate
		, d.AmountBase, d.AmountBase, 0, d.Amount, 0
		, d.PaymentNumber, CASE WHEN  ISNULL(d.BankID,'')<>'' THEN d.DepositDate ELSE NULL END
		, CASE WHEN  ISNULL(d.BankID,'')<>'' THEN b.CurrencyId ELSE h.CurrencyID END
		, d.ExchRate 
		, d.FiscalPeriod, d.FiscalYear
		, CASE WHEN  ISNULL(d.BankID,'')<>'' THEN d.FiscalPeriod ELSE 0 END,	CASE WHEN  ISNULL(d.BankID,'')<>'' THEN d.FiscalYear ELSE 0 END
		, h.TermsCode, d.BankID, CASE WHEN  ISNULL(d.BankID,'')<>'' THEN b.CurrencyId ELSE NULL END PmtCurrencyId
		, CASE WHEN  ISNULL(d.BankID,'')<>'' THEN d.ExchRate ELSE 1 END PmtExchRate
		, d.Notes, @PostRun, d.ID
	FROM #PostTransList s 
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	LEFT JOIN dbo.tblSmBankAcct b ON d.BankID = b.BankId	
    WHERE d.PostRun IS NULL
	
	--debit memo of deposit 

	INSERT INTO  #TransPostDeposit
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn
		, CheckNum, CheckDate, CurrencyId
		, ExchRate
		, GLPeriod, FiscalYear, CheckPeriod, CheckYear
		, TermsCode, BankID, PmtCurrencyId, PmtExchRate, Notes, PostRun, TransId) 

	SELECT h.VendorId, 'Deposit' + d.TransID , 1, 0, h.DistCode,d.DepositDate,d.DepositDate,d.DepositDate
		,-1* d.AmountBase, -1* d.AmountBase, 0, -1* d.Amount, 0
		, NULL,	NULL,CASE WHEN  ISNULL(d.BankID,'')<>'' THEN b.CurrencyId ELSE h.CurrencyID END
		, d.ExchRate
		, d.FiscalPeriod, d.FiscalYear, 0, 0
		, h.TermsCode,NULL, NULL ,1	,d.Notes,@PostRun, d.ID	
	FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	LEFT JOIN dbo.tblSmBankAcct b ON d.BankID = b.BankId	
	WHERE d.PostRun IS NULL
	
	
	--Update OpenInvoice table
	INSERT INTO dbo.tblApOpenInvoice 
		(VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, PmtCurrencyId, 
		PmtExchRate,  Notes, PostRun, TransId) 
	SELECT VendorID, InvcNum, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyID, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, 
		PmtCurrencyId, PmtExchRate,  Notes, PostRun, TransId
	FROM #TransPostDeposit

	--Payables Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping]
		, TransDate, PostDate
		, Descr
		, Reference, GlAcct, DR, CR, FiscalYear
		, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId
		, DebitAmtFgn
		, CreditAmtFgn
		, Amount
		, Amountfgn
		, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, d.FiscalPeriod, 99999, 400
		, d.DepositDate, @WksDate
		, CASE WHEN SUBSTRING(d.Notes, 1, 30) ='' THEN  'Deposit'+d.TransID 
			   WHEN SUBSTRING(d.Notes, 1, 30) IS NULL THEN 'Deposit'+d.TransID 
			   ELSE SUBSTRING(d.Notes, 1, 30) END	
		, h.VendorId, dc.PayablesGLAcct, 0, d.AmountBase,d.FiscalYear
		, d.TransID,NULL,0
		, CASE WHEN  @MCYn = 1  THEN ah.CurrencyID ELSE @CurrBase END
		, 0
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
		, -d.AmountBase
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN -1*d.Amount ELSE -1*d.AmountBase END
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END

	FROM dbo.tblPoTransHeader h 
	INNER JOIN #PostTransList p ON h.TransId = p.TransId 
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	LEFT JOIN dbo.tblApDistCode dc ON h.DistCode = dc.DistCode
	LEFT JOIN dbo.tblGlAcctHdr ah ON dc.PayablesGLAcct = ah.AcctId 
	WHERE d.PostRun IS NULL

	--Deposit Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], TransDate, PostDate
		, Descr
		, Reference, GlAcct, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId
		, DebitAmtFgn
		, CreditAmtFgn,Amount
		, Amountfgn
		, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, d.FiscalPeriod, 99999, 401, d.DepositDate, @WksDate
		, CASE WHEN SUBSTRING(d.Notes, 1, 30) ='' THEN  'Deposit'+d.TransID 
			   WHEN SUBSTRING(d.Notes, 1, 30) IS NULL THEN 'Deposit'+d.TransID 
			   ELSE SUBSTRING(d.Notes, 1, 30) END	
		, h.VendorId, dc.DepositGLAcct, d.AmountBase,0 ,d.FiscalYear, d.TransID,NULL,0
		, CASE WHEN  @MCYn = 1  THEN ah.CurrencyID ELSE @CurrBase END
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
		, 0 ,d.AmountBase
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
		, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM dbo.tblPoTransHeader h 
	INNER JOIN #PostTransList p ON h.TransId = p.TransId 
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	LEFT JOIN dbo.tblApDistCode dc ON h.DistCode = dc.DistCode 
	LEFT JOIN dbo.tblGlAcctHdr ah ON d.DepositGLAcct = ah.AcctId 
	WHERE d.PostRun IS NULL


	UPDATE dbo.tblPoTransDeposit SET InvoiceCounter =i.[Counter], DepositGLAcct =dc.DepositGLAcct,PostRun =@PostRun
	FROM dbo.tblPoTransDeposit d
	INNER JOIN ( SELECT [Counter],DistCode,TransID FROM tblApOpenInvoice WHERE PostRun =@PostRun AND GrossAmtDueFgn < 0) i
	ON  i.TransID = CAST(d.ID AS nvarchar(255))
	INNER JOIN tblApDistCode dc ON i.DistCode = dc.DistCode
	WHERE d.PostRun IS NULL

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_PostDeposits_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_PostDeposits_proc';



CREATE PROCEDURE dbo.trav_PoTransPost_OrphanDeposits_proc
AS
BEGIN TRY

	DECLARE @WksDate datetime
	DECLARE	@PrecCurr smallint,@CurrBase pCurrency ,@PostRun nvarchar(14),@PostAsHeld bit,@wksPeriod smallint, @wksYear smallint, @MCYn bit
	
	--Retrieve global values

	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @PostAsHeld = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Held'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @wksPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'WrkStnPeriod'
	SELECT @wksYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'WrkStnYear'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'

	IF @PostRun IS NULL  OR @PostAsHeld IS NULL OR @WksDate IS NULL OR @wksPeriod IS NULL OR @wksYear IS NULL OR @MCYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #TransPostOrphan
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
	
	--Invoice

	INSERT INTO  #TransPostOrphan
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate,
	  GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn, 
	  CheckNum, CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,
	  TermsCode, BankID, PmtCurrencyId, PmtExchRate, Notes, PostRun, TransId,GroupID) 

	SELECT i.VendorId,'Deposit'+ d.TransID, 1, 0, i.DistCode, @WksDate, @WksDate, @WksDate
			,d.AmountBase, d.AmountBase, 0, d.Amount, 0
			,NULL,  NULL,i.CurrencyId, i.ExchRate , @wksPeriod, @wksYear, 0, 0
			,i.TermsCode, NULL,NULL,1, d.Notes, @PostRun, d.ID, d.InvoiceCounter		
	FROM dbo.tblPoTransDeposit d
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	WHERE h.TransId IS NULL
	
	--Debit Memo

	INSERT INTO  #TransPostOrphan
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode, InvoiceDate, NetDueDate, DiscDueDate,
	  GrossAmtDue, BaseGrossAmtDue, DiscAmt, GrossAmtDueFgn, DiscAmtFgn, 
	  CheckNum, CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,
	  TermsCode, BankID, PmtCurrencyId, PmtExchRate, Notes, PostRun, TransId,GroupID) 

	SELECT i.VendorId,'Deposit'+ d.TransID, CASE WHEN @PostAsHeld = 1 THEN 1 ELSE 0 END, 0, i.DistCode, @WksDate, @WksDate, @WksDate
			,-1 * d.AmountBase,-1 * d.AmountBase, 0, -1 * d.Amount, 0
			,NULL,  NULL,i.CurrencyId, i.ExchRate , @wksPeriod, @wksYear, 0, 0
			,i.TermsCode, NULL,NULL,1, d.Notes, @PostRun, d.ID, NULL		

	FROM dbo.tblPoTransDeposit d
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter	
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	WHERE h.TransId IS NULL

	--Update OpenInvoice table
	INSERT INTO dbo.tblApOpenInvoice 
		(VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, PmtCurrencyId, 
		PmtExchRate,  Notes, PostRun, TransId, GroupID) 
	SELECT VendorID, InvcNum, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyID, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, 
		PmtCurrencyId, PmtExchRate,  Notes, PostRun, TransId,GroupID
	FROM #TransPostOrphan

	--Payables Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping]
			, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn,Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 400
			, @WksDate, @WksDate, SUBSTRING(d.Notes, 1, 30), i.VendorId, dc.PayablesGLAcct, d.AmountBase, 0,@wksYear, NULL ,NULL, 0
			, CASE WHEN  @MCYn = 1  THEN ah.CurrencyID ELSE @CurrBase END
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
			, 0 ,d.AmountBase
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM dbo.tblPoTransDeposit d
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter
	INNER JOIN dbo.tblApDistCode dc ON i.DistCode = dc.DistCode
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	LEFT JOIN dbo.tblGlAcctHdr ah ON dc.PayablesGLAcct = ah.AcctId
	WHERE h.TransId IS NULL


	--Deposit Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping]
			, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn
			, Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 401
			, @WksDate, @WksDate, SUBSTRING(d.Notes, 1, 30), i.VendorID, d.DepositGLAcct,0, d.AmountBase, @wksYear, NULL ,NULL, 0
			, CASE WHEN  @MCYn = 1  THEN ah.CurrencyID ELSE @CurrBase END
			, 0
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.Amount ELSE d.AmountBase END
			,-d.AmountBase
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN -1*d.Amount ELSE -1*d.AmountBase END
			, CASE WHEN  @MCYn = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM dbo.tblPoTransDeposit d
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	LEFT JOIN dbo.tblGlAcctHdr ah ON d.DepositGLAcct = ah.AcctId
	WHERE h.TransId IS NULL

	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OrphanDeposits_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OrphanDeposits_proc';


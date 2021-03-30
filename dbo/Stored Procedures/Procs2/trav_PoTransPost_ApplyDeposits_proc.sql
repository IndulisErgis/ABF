
CREATE PROCEDURE dbo.trav_PoTransPost_ApplyDeposits_proc
AS
BEGIN TRY

	DECLARE @PrecCurr smallint,@CurrBase pCurrency,@InHsVendor nvarchar(10),@WksDate datetime,
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
		OR  @wksPeriod IS NULL OR @wksYear IS NULL OR @MCYn IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #TransPostDeposit1a
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
	CREATE TABLE #ApplyAmount
	(
		ID bigint ,
		AmountToApply pDecimal)
	

	INSERT INTO #ApplyAmount( ID,AmountToApply)

	SELECT  d.ID, CASE WHEN d.RunningBalance <= v.InvoiceBalance THEN d.DepositBalance
	WHEN d.RunningBalance > v.InvoiceBalance AND (d.RunningBalance - d.DepositBalance) < v.InvoiceBalance THEN 
		v.InvoiceBalance - (d.RunningBalance - d.DepositBalance)
	ELSE 0 END AS AmountToApply
	FROM
	(
		SELECT a.Id, a.TransId, a.DepositBalance,
		(
			SELECT SUM(b.DepositBalance) 
			 FROM (	SELECT ROW_NUMBER() OVER (ORDER BY TransId, DepositDate, Amount - AmountApplied, ID) as RowID, ID, TransId, Amount - AmountApplied AS DepositBalance
					FROM dbo.tblPoTransDeposit 
					WHERE PostRun IS NOT NULL AND Amount - AmountApplied > 0
					) b
			WHERE b.RowID <= a.RowID AND b.TransId = a.TransId
		) AS RunningBalance
		FROM 
		(
			SELECT ROW_NUMBER() OVER (ORDER BY TransId, DepositDate, Amount - AmountApplied, ID) as RowID, ID, TransId, Amount - AmountApplied AS DepositBalance
			FROM dbo.tblPoTransDeposit 
			WHERE PostRun IS NOT NULL AND Amount - AmountApplied > 0
		) a
	) d --deposit balance
 	INNER JOIN 
	(
		SELECT i.TransId, i.InvoiceDue - ISNULL(a.AppliedTotal, 0) AS InvoiceBalance 
		FROM
		(
			SELECT TransId, SUM(PostTaxableFgn + PostNonTaxableFgn + PostSalesTaxFgn + PostFreightFgn + PostMiscFgn - PostPrepaidFgn
						+CurrTaxableFgn + CurrNonTaxableFgn + CurrSalesTaxFgn + CurrFreightFgn + CurrMiscFgn - CurrPrepaidFgn) InvoiceDue
			FROM dbo.tblPoTransInvoiceTot
			WHERE (PostTaxableFgn + PostNonTaxableFgn + PostSalesTaxFgn + PostFreightFgn + PostMiscFgn - PostPrepaidFgn
					+CurrTaxableFgn + CurrNonTaxableFgn + CurrSalesTaxFgn + CurrFreightFgn + CurrMiscFgn - CurrPrepaidFgn) > 0
			GROUP BY TransId
		) i 
		LEFT JOIN 
		(
			SELECT TransID, SUM(AmountApplied) AS AppliedTotal
			FROM dbo.tblPoTransDeposit
			GROUP BY TransID
		) a
		ON i.TransId = a.TransID 
		WHERE i.InvoiceDue - ISNULL(a.AppliedTotal, 0) > 0
	) v 
	ON d.TransID = v.TransId --invoice balance
	INNER JOIN #PostTransList b ON v.TransId = b.TransId 

	 --invoice 

	 INSERT INTO  #TransPostDeposit1a
	(	VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode 
		, InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue
		, BaseGrossAmtDue
		, DiscAmt, GrossAmtDueFgn, DiscAmtFgn,  CheckNum 
		, CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,TermsCode
		, BankID, PmtCurrencyId, PmtExchRate 
		, Notes, PostRun, TransId	  
		, GroupID) 

	SELECT h.VendorId,'Deposit' + d.TransId, 1,0,	i.DistCode
		, @WksDate,@WksDate,@WksDate
		, CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END  
		, CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply = 0 THEN d.AmountBase-d.AmountAppliedBase 
				ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
				END  
		, 0,ap.AmountToApply,0,	NULL,NULL,i.CurrencyID,i.ExchRate,@wksPeriod,@wksYear,0,0,i.TermsCode
		, NULL,NULL,1
		, d.Notes,@PostRun,d.ID			
		, d.InvoiceCounter	
	FROM #PostTransList s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN #ApplyAmount ap ON ap.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter

	
	--Debit Memo

	 INSERT INTO  #TransPostDeposit1a
	( VendorID, InvcNum,PaidStatus, Ten99InvoiceYN, DistCode , InvoiceDate, NetDueDate, DiscDueDate
		, GrossAmtDue
		, BaseGrossAmtDue
		, DiscAmt, GrossAmtDueFgn, DiscAmtFgn
		, CheckNum , CheckDate, CurrencyId, ExchRate, GLPeriod, FiscalYear, CheckPeriod, CheckYear,TermsCode, BankID, PmtCurrencyId, PmtExchRate 
		, Notes, PostRun, TransId 
		, GroupID) 

	SELECT h.VendorId,'Deposit' + d.TransId, CASE WHEN @PostAsHeld=1 THEN 1 ELSE 0 END,0,	i.DistCode,@WksDate,@WksDate,@WksDate
		, -1 * CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END 
		, CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply = 0 THEN -1*(d.AmountBase-d.AmountAppliedBase )
				ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((-1*(ap.AmountToApply / d.ExchRate)),@PrecCurr) END
				END
		, 0,-1 * ap.AmountToApply,0
		, NULL,NULL,i.CurrencyID,i.ExchRate,@wksPeriod,@wksYear,0,0,i.TermsCode,NULL,NULL,1
		, d.Notes,@PostRun,d.ID
		, NULL	
	FROM #PostTransList s
	INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDeposit d ON h.TransID = d.TransID
	INNER JOIN #ApplyAmount ap ON ap.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter


	--Update OpenInvoice table
	INSERT INTO dbo.tblApOpenInvoice 
		(VendorID, InvoiceNum, Status, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyId, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, PmtCurrencyId, 
		PmtExchRate,  Notes, PostRun, TransId, GroupID) 
	SELECT VendorID, InvcNum, PaidStatus, Ten99InvoiceYN, DistCode, TermsCode, InvoiceDate, 
		NetDueDate, DiscDueDate, DiscAmt, DiscAmtFgn, GrossAmtDue, BaseGrossAmtDue, GrossAmtDueFgn, 
		CheckNum, CheckDate, CurrencyID, ExchRate, GlPeriod, FiscalYear, CheckYear, CheckPeriod, BankID, 
		PmtCurrencyId, PmtExchRate,  Notes, PostRun, TransId, GroupID
	FROM #TransPostDeposit1a

	--Payables Entry
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], TransDate, PostDate
			, Descr
			, Reference, GlAcct
			, DR
			, CR, FiscalYear, 	LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn
			, Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 400
			 , @WksDate, @WksDate
			 , CASE WHEN SUBSTRING(d.Notes, 1, 30) IS NULL THEN 'Deposit' + d.TransId
					WHEN SUBSTRING(d.Notes, 1, 30) ='' THEN 'Deposit' + d.TransId 
					ELSE SUBSTRING(d.Notes, 1, 30) END
			 , h.VendorId, dc.PayablesGLAcct
			 , CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply =0 THEN (d.AmountBase - d.AmountAppliedBase) 
					ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
					END 
			 , 0,@wksYear
			 , d.TransID,NULL,0
			 , CASE WHEN @MCYN = 1 THEN ah.CurrencyID  ELSE @CurrBase END
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN ap.AmountToApply 
					ELSE 
						CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply =0 THEN (d.AmountBase - d.AmountAppliedBase) 
							 ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
							 END
					END 
			 , 0
			 , CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply =0 THEN (d.AmountBase - d.AmountAppliedBase) 
					ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
					END 
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN ap.AmountToApply 
					ELSE 
						CASE WHEN (d.Amount -d.AmountApplied) - ap.AmountToApply =0 THEN (d.AmountBase - d.AmountAppliedBase) 
							 ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
							 END
					END 
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM dbo.tblPoTransDeposit d
	INNER JOIN #ApplyAmount ap ON ap.ID = d.ID
	INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter 
	INNER JOIN dbo.tblApDistCode dc ON i.DistCode = dc.DistCode 
	INNER JOIN dbo.tblGlAcctHdr ah ON dc.PayablesGLAcct = ah.AcctId


	--Deposit Entry

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, [Grouping], TransDate, PostDate
			, Descr
			, Reference, GlAcct
			, DR
			, CR
			, FiscalYear, 	LinkID, LinkIDSub, LinkIDSubLine
			, CurrencyId
			, DebitAmtFgn
			, CreditAmtFgn			
			, Amount
			, Amountfgn
			, ExchRate)

	SELECT @PostRun, d.TransID,'Deposit' + d.TransId, @wksPeriod, 99999, 401,@WksDate, @WksDate
			 , CASE WHEN SUBSTRING(d.Notes, 1, 30) IS NULL THEN 'Deposit' + d.TransId
					WHEN SUBSTRING(d.Notes, 1, 30) ='' THEN 'Deposit' + d.TransId 
					ELSE SUBSTRING(d.Notes, 1, 30) END
			 , h.VendorId, d.DepositGLAcct
			 , 0
			 , CASE WHEN (d.Amount -  d.AmountApplied)-ap.AmountToApply = 0 THEN d.AmountBase - d.AmountAppliedBase
					ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
					END 
			 , @wksYear, d.TransID,NULL,0
			 , CASE WHEN @MCYN = 1 THEN ah.CurrencyID ELSE @CurrBase END
			 , 0
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN ap.AmountToApply 
					ELSE
						CASE WHEN (d.Amount -  d.AmountApplied)-ap.AmountToApply = 0 THEN d.AmountBase - d.AmountAppliedBase
							 ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE Round((ap.AmountToApply / d.ExchRate),@PrecCurr) END
							 END
					END  
			 , CASE WHEN (d.Amount -  d.AmountApplied)-ap.AmountToApply = 0 THEN -1*(d.AmountBase - d.AmountAppliedBase)
					ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND(-1*(ap.AmountToApply / d.ExchRate),@PrecCurr) END
					END
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN -1*ap.AmountToApply 
					ELSE
						CASE WHEN (d.Amount -  d.AmountApplied)-ap.AmountToApply = 0 THEN -1*(d.AmountBase - d.AmountAppliedBase)
							 ELSE CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND(-1*(ap.AmountToApply / d.ExchRate),@PrecCurr) END
							 END
					END  
			 , CASE WHEN @MCYN = 1 AND ah.CurrencyID <> @CurrBase THEN d.ExchRate ELSE 1 END
	FROM dbo.tblPoTransDeposit d
	INNER JOIN #ApplyAmount ap ON ap.ID = d.ID
	INNER JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransId
	INNER JOIN dbo.tblApOpenInvoice i ON i.[Counter] = d.InvoiceCounter 
	INNER JOIN dbo.tblGlAcctHdr ah ON d.DepositGLAcct = ah.AcctId


	UPDATE dbo.tblPoTransDeposit 
		SET AmountApplied =AmountApplied + ap.AmountToApply,
		AmountAppliedBase =	CASE WHEN (d.Amount-d.AmountApplied	)- ap.AmountToApply = 0 THEN d.AmountBase
								 ELSE AmountAppliedBase+ CASE WHEN d.ExchRate  = 0 THEN 0 ELSE ROUND((ap.AmountToApply / d.ExchRate),@PrecCurr) END
								 END 
	FROM dbo.tblPoTransDeposit d
	INNER JOIN #ApplyAmount ap ON ap.ID = d.ID
	INNER JOIN dbo.tblApOpenInvoice i ON  d.InvoiceCounter =i.[Counter]	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ApplyDeposits_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_ApplyDeposits_proc';


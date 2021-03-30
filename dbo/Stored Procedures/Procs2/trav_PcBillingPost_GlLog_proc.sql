
CREATE PROCEDURE dbo.trav_PcBillingPost_GlLog_proc
AS
BEGIN TRY
	DECLARE @PostRun pPostRun, @CurrBase pCurrency, @PrecCurr tinyint, @WksDate datetime,@CompId nvarchar(3),
		@PostDtlYn bit, @SourceCode nvarchar(2), @SalesTaxDescr nvarchar(30), @MCYn bit, @PCGlYn bit, @ARDescr nvarchar(30), 
		@CustDepositAcct pGlAcct  

	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @SalesTaxDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'SalesTaxDescr'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @PCGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PcGlYn'
	SELECT @ARDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'ARDescr'
	SELECT @CustDepositAcct = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CustDepositAcct' 
		
	IF @PostRun IS NULL OR @CurrBase IS NULL OR @PrecCurr IS NULL OR @WksDate IS NULL OR @CompId IS NULL OR @PostDtlYn IS NULL 
		OR @SalesTaxDescr IS NULL OR @ARDescr IS NULL OR @MCYn IS NULL OR @PCGlYn IS NULL OR @CustDepositAcct is NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	CREATE TABLE #BillingPostLog
	(
		[FiscalYear] smallint NOT NULL,
		[FiscalPeriod] smallint NOT NULL,
		[TransDate] [datetime] NULL,
		[Grouping] smallint NOT NULL,
		[GlAccount] [pGlAcct] NULL,
		[Amount] [pDecimal] NOT NULL,
		[DebitAmount] [pDecimal] NOT NULL,
		[CreditAmount] [pDecimal] NOT NULL,
		[DebitAmountFgn] [pDecimal] NOT NULL,
		[CreditAmountFgn] [pDecimal] NOT NULL,
		[Reference] [nvarchar](15) NULL,
		[DistCode] [dbo].[pDistCode] NULL,	
		[Description] [nvarchar](30) NULL,
		[TransId] int NOT NULL,
		[BatchId] pBatchId NOT NULL, 
		[CurrencyId] pCurrency Null, 
		[ExchRate] pDecimal Null Default(1),
		[LinkID] nvarchar(15) Null, 
		[LinkIDSub] nvarchar(15) Null, 
		[LinkIDSubLine] int Null
	)
	
	--Tax Locations
	CREATE TABLE #zzTax
	(
		TransId pTransId, 
		InvcNum pInvoiceNum Null, 
		FiscalYear smallint, 
		FiscalPeriod smallint, 
		TaxAmount pDecimal Null,
		InvcDate datetime,
		TaxLocID pTaxLoc Null,
		CustID pCustId Null, 
		DistCode pDistCode Null, 
		LiabilityAcct pGlAcct Null,
		BatchId pBatchId 
	)
	
	SET @SourceCode = 'JC'
	 
	 --Deposits GL Entries    
	 BEGIN 	 
	    
	  INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,    
	   CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)    
	  SELECT h.FiscalYear,h.FiscalPeriod, 908 AS [Grouping], @CustDepositAcct,     
	   SIGN(h.TransType) * d.DepositAmtApply, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + 'Dep Applied' , 1, 30) AS [Description],     
	   CASE WHEN SIGN(h.TransType) * d.DepositAmtApply > 0 THEN ABS(d.DepositAmtApply) ELSE 0 END AS DebitAmount,    
	   CASE WHEN SIGN(h.TransType) * d.DepositAmtApply > 0 THEN 0 ELSE ABS(d.DepositAmtApply) END AS CreditAmount,    
	   CASE WHEN SIGN(h.TransType) * d.DepositAmtApply > 0 THEN ABS(d.DepositAmtApply) ELSE 0 END AS DebitAmountFgn,    
	   CASE WHEN SIGN(h.TransType) * d.DepositAmtApply > 0 THEN 0 ELSE ABS(d.DepositAmtApply) END AS CreditAmounFgn,    
	   h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.Id, @CurrBase, 1    
	   FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId    
	   INNER JOIN tblPcInvoiceDeposit d ON h.TransId = d.TransId      
	  WHERE h.VoidYn = 0   
	    
	  INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,    
	   CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)    
	  SELECT h.FiscalYear,h.FiscalPeriod, 908 AS [Grouping], dc.GLAcctReceivables,     
	   -SIGN(h.TransType) * CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase 
			THEN ROUND(d.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr)) 
			ELSE d.DepositAmtApply END, 
	   h.CustId,  SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + 'Dep Applied', 1, 30) AS [Description],     
	   CASE WHEN -SIGN(h.TransType) * d.DepositAmtApply > 0 THEN ABS(d.DepositAmtApply) ELSE 0 END AS DebitAmount,    
	   CASE WHEN -SIGN(h.TransType) * d.DepositAmtApply > 0 THEN 0 ELSE ABS(d.DepositAmtApply) END AS CreditAmount,      
	   CASE WHEN -SIGN(h.TransType) * d.DepositAmtApply > 0 THEN ABS(CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase 
			THEN ROUND(d.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr)) 
			ELSE d.DepositAmtApply END) ELSE 0 END AS DebitAmount,    
	   CASE WHEN -SIGN(h.TransType) * d.DepositAmtApply > 0 THEN 0 ELSE ABS(CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase 
			THEN ROUND(d.DepositAmtApply * h.ExchRate, ISNULL(c.CurrDecPlaces, @PrecCurr)) 
			ELSE d.DepositAmtApply END) END AS CreditAmount, 
	   h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.Id, 
	   CASE WHEN @MCYn = 1 AND @PCGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END, 
			CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase THEN h.ExchRate ELSE 1.0 END
	   FROM #PostTransList t   
	   INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId    
	   INNER JOIN dbo.tblPcInvoiceDeposit d ON h.TransId = d.TransId      
	   INNER JOIN dbo.tblArDistCode dc ON dc.DistCode=h.DistCode  
	   LEFT JOIN dbo.tblGlAcctHdr g ON dc.GLAcctReceivables = g.AcctId 
	   LEFT JOIN #tmpCurrencyList c ON h.CurrencyID = c.CurrencyId
	  WHERE h.VoidYn = 0  
	      
	 END    
   
	--WIP Account 
	BEGIN

		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 901 AS [Grouping], a.GLAcctWIP, 
			-SIGN(h.TransType) * a.ExtIncome, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmount,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmounFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND a.ExtIncome <> 0 AND a.[Type] NOT IN (6,7) --Not fixed fee billing and Credit Memo
		
	END
	
	--Income Account
	BEGIN
	
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 902 AS [Grouping], a.GLAcctIncome, 
			-SIGN(h.TransType) * a.ExtIncome, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmount,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(-SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND a.ExtIncome <> 0 AND a.[Type] <> 6 --Not fixed fee billing
	
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 902 AS [Grouping], a.GLAcctIncome, 
			-SIGN(h.TransType) * d.ExtPrice, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice > 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS DebitAmount,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice < 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS CreditAmount,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice > 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice < 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail k ON a.ProjectDetailId = k.Id
			INNER JOIN dbo.tblPcProject p ON k.ProjectId = p.Id
		WHERE h.VoidYn = 0 AND d.ExtPrice <> 0 AND a.[Type] = 6 AND p.[Type] = 0--Fixed fee billing, General project
	END
	
	--Fixed Fee Billing
	BEGIN
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 903 AS [Grouping], a.GLAcctFixedFeeBilling, 
			-SIGN(h.TransType) * d.ExtPrice, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice > 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS DebitAmount,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice < 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS CreditAmount,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice > 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SIGN(h.TransType) * d.ExtPrice < 0 THEN ABS(-SIGN(h.TransType) * d.ExtPrice) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
			INNER JOIN dbo.tblPcProjectDetail k ON a.ProjectDetailId = k.Id
			INNER JOIN dbo.tblPcProject p ON k.ProjectId = p.Id
		WHERE h.VoidYn = 0 AND d.ExtPrice <> 0 AND a.[Type] = 6 AND p.[Type] = 1--Fixed fee billing, Job Costing project
	END	
	
	--Accrued Income Account
	BEGIN
	
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 904 AS [Grouping], a.GLAcctAccruedIncome, 
			SIGN(h.TransType) * a.ExtIncome, h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmount,
			CASE WHEN SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmount,
			CASE WHEN SIGN(h.TransType) * a.ExtIncome > 0 THEN ABS(SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN SIGN(h.TransType) * a.ExtIncome < 0 THEN ABS(SIGN(h.TransType) * a.ExtIncome) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND a.ExtIncome <> 0 AND a.[Type] NOT IN (6,7) --Not fixed fee billing and Credit Memo
		
	END	
	
	--Adjustment Account
	BEGIN
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT h.FiscalYear,h.FiscalPeriod, 905 AS [Grouping], a.GLAcctAdjustments, 
			-SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome), h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + ISNULL(Descr,''), 1, 30) AS [Description], 
			CASE WHEN -SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome) > 0 THEN ABS(-SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome)) ELSE 0 END AS DebitAmount,
			CASE WHEN -SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome) < 0 THEN ABS(-SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome)) ELSE 0 END AS CreditAmount,
			CASE WHEN -SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome) > 0 THEN ABS(-SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome)) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome) < 0 THEN ABS(-SIGN(h.TransType) * (d.ExtPrice - a.ExtIncome)) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, d.EntryNum, @CurrBase, 1
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceDetail d ON h.TransId = d.TransId
			INNER JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id
		WHERE h.VoidYn = 0 AND (d.ExtPrice - a.ExtIncome) <> 0 AND a.[Type] <> 6 --Not fixed fee billing
	END
	
	--Liability Account
	BEGIN
	
		--tax detail                                         
		INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, FiscalPeriod, TaxAmount
			, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, BatchId)
		SELECT h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), h.FiscalYear, h.FiscalPeriod
			, Sign(h.TransType) * -1 * TaxAmt
			, h.InvcDate, t.TaxLocID, h.CustID, h.DistCode, t.LiabilityAcct, h.BatchId
		FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
			INNER JOIN dbo.tblPcInvoiceTax t ON h.TransId = t.TransId
		WHERE h.VoidYn = 0 AND t.TaxAmt <> 0
				
		--tax adjustments
		INSERT INTO #zzTax (TransId, InvcNum, FiscalYear, FiscalPeriod, TaxAmount
			, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, BatchId)
		SELECT h.TransId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), h.FiscalYear, h.FiscalPeriod
			, Sign(h.TransType) * -1 * TaxAmtAdj
			, h.InvcDate, h.TaxLocAdj, h.CustID, h.DistCode, t.GlAcct, h.BatchId
		FROM #PostTransList l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId
			LEFT JOIN dbo.tblSmTaxLoc t on h.TaxLocAdj = t.TaxLocId
		WHERE h.VoidYn = 0 AND TaxAmtAdj <> 0
		
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)
		SELECT FiscalYear, FiscalPeriod, 906, LiabilityAcct, SUM(TaxAmount), CustId, 
			Substring(InvcNum + ' / ' + @SalesTaxDescr + ' / ' + TaxLocID, 1, 30) AS [Description],
			CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END AS DebitAmount, 
			CASE WHEN SUM(TaxAmount) < 0 THEN ABS(SUM(TaxAmount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(TaxAmount) > 0 THEN SUM(TaxAmount) ELSE 0 END AS DebitAmountFgn, 
			CASE WHEN SUM(TaxAmount) < 0 THEN ABS(SUM(TaxAmount)) ELSE 0 END AS CreditAmountFgn,
			InvcDate, DistCode, BatchId, TransId, TransId, InvcNum, 0, @CurrBase, 1
		FROM #zzTax
		GROUP BY FiscalYear, FiscalPeriod, LiabilityAcct, CustId, InvcNum, TaxLocID, InvcDate, DistCode, BatchId, TransId
		HAVING SUM(TaxAmount) <> 0
		
	END
	
	--AR Account
	BEGIN
		INSERT INTO #BillingPostLog(FiscalYear,FiscalPeriod,[Grouping],GlAccount,Amount,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,TransDate,DistCode,BatchId,TransId,LinkID,LinkIDSub,LinkIDSubLine,CurrencyId,ExchRate)	
		SELECT h.FiscalYear,h.FiscalPeriod, 907 AS [Grouping], d.GLAcctReceivables, 
			SIGN(h.TransType) * (CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase 
				THEN h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn 
				ELSE h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.TaxAmtAdj END) AS Amount, 
			h.CustId, SUBSTRING(ISNULL(h.InvcNum, t.DefaultInvoiceNumber) + ' / ' + @ARDescr, 1, 30) AS [Description], 
			CASE WHEN SIGN(h.TransType) * (h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.TaxAmtAdj) > 0 THEN ABS(SIGN(h.TransType) * (h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.TaxAmtAdj)) ELSE 0 END AS DebitAmount,
			CASE WHEN SIGN(h.TransType) * (h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.TaxAmtAdj) < 0 THEN ABS(SIGN(h.TransType) * (h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.TaxAmtAdj)) ELSE 0 END AS CreditAmount,
			CASE WHEN SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn) > 0 THEN ABS(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn)) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn) < 0 THEN ABS(SIGN(h.TransType) * (h.TaxSubtotalFgn + h.NonTaxSubtotalFgn + h.SalesTaxFgn + h.TaxAmtAdjFgn)) ELSE 0 END AS CreditAmountFgn,
			h.InvcDate, h.DistCode, h.BatchId, h.TransId, h.TransId, h.InvcNum, 0, CASE WHEN @MCYn = 1 AND @PCGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END, 
			CASE WHEN @MCYn = 1 AND @PCGlYn = 1 AND ISNULL(g.CurrencyID,@CurrBase) <> @CurrBase THEN h.ExchRate ELSE 1.0 END
		FROM #PostTransList t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.tblArDistCode d ON h.DistCode = d.DistCode
			LEFT JOIN dbo.tblGlAcctHdr g ON d.GLAcctReceivables = g.AcctId
		WHERE h.VoidYn = 0
	END
	
	IF @PostDtlYn = 0
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, SUM(Amount), 'JC', 
			CASE WHEN [Grouping] = 901 THEN 'Work in Process'
				WHEN [Grouping] = 902 THEN 'Income'
				WHEN [Grouping] = 903 THEN 'Fixed Fee Billing'
				WHEN [Grouping] = 904 THEN 'Accrued Income'
				WHEN [Grouping] = 905 THEN 'Adjustment'
				WHEN [Grouping] = 906 THEN @SalesTaxDescr
				WHEN [Grouping] = 907 THEN @ARDescr 
				WHEN [Grouping] = 908 THEN 'Deposit Applied' END,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmount,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmount,
			CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS DebitAmountFgn,
			CASE WHEN -SUM(Amount) > 0 THEN ABS(SUM(Amount)) ELSE 0 END AS CreditAmountFgn,
			@SourceCode, @WksDate, @WksDate, @CurrBase, 1, @CompId
		FROM #BillingPostLog
		GROUP BY FiscalYear, FiscalPeriod, [Grouping], GlAccount
	END
	ELSE
	BEGIN
		INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,[Grouping],GlAccount,AmountFgn,Reference,[Description],DebitAmount,
			CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompId,DistCode,BatchId, 
			LinkID,LinkIDSub,LinkIDSubLine)
		SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAccount, Amount, Reference, [Description], DebitAmount, 
			CreditAmount,DebitAmountFgn, CreditAmountFgn, @SourceCode, @WksDate, TransDate, CurrencyId, ExchRate, @CompId, DistCode, BatchId,
			LinkID,LinkIDSub,LinkIDSubLine 
		FROM #BillingPostLog
		WHERE CreditAmount <> 0 OR DebitAmount <> 0 
	END
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingPost_GlLog_proc';


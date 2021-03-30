
CREATE PROCEDURE dbo.trav_ArCashReceiptPost_BuildLog_proc
AS
--PET:http://webfront:801/view.php?id=234649
--PET:http://webfront:801/view.php?id=237482
--MOD:Deposit Invoices
--PET:http://webfront:801/view.php?id=241362
--PET:http://problemtrackingsystem.osas.com/view.php?id=271494

BEGIN TRY
	DECLARE	@PostRun pPostRun
	, @MCYn bit
	, @ArGlYn bit
	, @ArGlDetailYn bit
	, @PostGainLossDtl bit
	, @CurrBase pCurrency
	, @WrkStnDate datetime
	, @ARDescr nvarchar(30)
	, @PaymentDescr nvarchar(30)
	, @DiscountDescr nvarchar(30)
	, @DepositDescr nvarchar(30)
	, @UnknownDescr nvarchar(30)
	, @GlAcctDisc pGlAcct
	, @CustDepositAcct pGlAcct
	, @CompId [sysname]     
	, @PrecCurr smallint

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @ArGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlYn'
	SELECT @ArGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlDetailYn'
	SELECT @PostGainLossDtl = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostGainLossDtl'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @ARDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'ARDescr'
	SELECT @PaymentDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'PaymentDescr'
	SELECT @DiscountDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'DiscountDescr'
	SELECT @UnknownDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'UnknownDescr'
	SELECT @GlAcctDisc = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'GlAcctDisc'
	SELECT @CustDepositAcct = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CustDepositAcct'
	SELECT @DepositDescr = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'DepositDescr'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PostRun IS NULL OR @MCYn IS NULL 
		OR @ArGlYn IS NULL 
		OR @ArGlDetailYn IS NULL OR @PostGainLossDtl IS NULL OR @CurrBase IS NULL 
		OR @WrkStnDate IS NULL 
		OR @ARDescr IS NULL OR @PaymentDescr IS NULL 
		OR @DiscountDescr IS NULL OR @UnknownDescr IS NULL
		OR @GlAcctDisc IS NULL
		OR @DepositDescr IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #ArTransPostLogDtl 
	(
		[Counter] int Not Null Identity(1, 1), 
		[PostRun] pPostRun Not Null, 
		[TransId] pTransId Null, 
		[EntryNum] int Null, 
		[Grouping] smallint Null, 
		[Amount] pDecimal Not Null, 
		[TransDate] datetime Null, 
		[PostDate] datetime Null, 
		[Descr] nvarchar(30) Null, 
		[SourceCode] nvarchar(2) Null, 
		[Reference] nvarchar(15) Null, 
		[DistCode] pDistCode Null,
		[GlAcct] pGlAcct Null, 
		[DR] pDecimal Null, 
		[CR] pDecimal Null, 
		[FiscalPeriod] smallint Null, 
		[FiscalYear] smallint Null, 
		[LinkID] nvarchar(15) Null, 
		[LinkIDSub] nvarchar(15) Null, 
		[LinkIDSubLine] int Null, 
		[CurrencyId] pCurrency Null, 
		[ExchRate] pDecimal Null Default(1), 
		[DebitAmtFgn] pDecimal Null Default(0), 
		[CreditAmtFgn] pDecimal Null Default(0)
	)

	--Prepayments
	Create Table #Temp2
	(
		hid nvarchar(8), 
		FiscalYear smallint, 
		GLPeriod smallint,
		CurrencyDebitAcct pCurrency Null,
		CurrencyRcvAcct pCurrency Null,    
		ExchRate pDecimal Null,
		InvcExchRate pDecimal Null,  
		GLAcctReceivables pGlAcct Null, 
		PmtDate datetime, 
		PmtAmt pDecimal Null,
		[Difference] pDecimal Null,
		PmtAmtFgn pDecimal Null,     
		DifferenceFgn pDecimal Null,     
		BankID pBankId Null, 
		DepositID pBatchId Null,
		InvcNum pInvoiceNum Null, 
		CustId pCustId Null, 
		GLAcctDebit pGlAcct Null, 
		DistCode pDistCode Null, 
		DID int,
		CalcGainLoss pDecimal NULL,
		InvcType smallint Null Default(1)
	)


	INSERT INTO #Temp2 (hid, FiscalYear, GLPeriod, CurrencyDebitAcct, CurrencyRcvAcct
		, ExchRate, InvcExchRate, GLAcctReceivables, PmtDate, PmtAmt, [Difference]
		, PmtAmtFgn, DifferenceFgn, BankID, DepositID, InvcNum
		, CustId, GLAcctDebit, DistCode, DID, CalcGainLoss, InvcType)
	SELECT Right(Cast(h.RcptHeaderId as nvarchar), 8), h.FiscalYear, h.GLPeriod, h.CurrencyId, h.CurrencyId
		, h.ExchRate, d.InvcExchRate
		, CASE WHEN h.CustId IS NULL THEN h.GLAcct ELSE dc.GLAcctReceivables END -- Use acct from header when no customer is identified
		, h.PmtDate, d.PmtAmt, d.[Difference], d.PmtAmtFgn, d.DifferenceFgn, h.BankID, h.DepositId
		, d.InvcNum, h.CustId
		, CASE	WHEN p.PmtType IN (3, 7) THEN  ISNULL(b.GlCashAcct, p.GLAcctDebit) 
				WHEN p.PmtType IN (1, 2, 6) THEN b.GlCashAcct ELSE p.GLAcctDebit END --ues the bank gl account for Cash, Check and Direct Debit 
		, d.DistCode, d.RcptDetailID, d.CalcGainLoss, d.InvcType
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	INNER JOIN dbo.tblArPmtMethod p ON h.PmtMethodId = p.PmtMethodID
	LEFT JOIN dbo.tblSmBankAcct b on p.BankId = b.BankId
	LEFT JOIN dbo.tblArDistCode dc ON d.DistCode = dc.DistCode --get AR Acct for header

	--retrieve currency from accounts when mc is enabled
	IF @MCYN = 1 AND @ArGlYn = 1
	BEGIN
		UPDATE #temp2 SET CurrencyDebitAcct = g.CurrencyID 
		FROM #temp2 h INNER JOIN dbo.tblGlAcctHdr g ON h.GLAcctDebit = g.AcctId
		
		UPDATE #temp2 SET CurrencyRcvAcct = g.CurrencyID 
		FROM #temp2 h INNER JOIN dbo.tblGlAcctHdr g ON h.GLAcctReceivables = g.AcctId
	END

	--Cash receipts that are applied to existing pro forma invoice	
	--GL entries for Deposit Receivables and Deposit Receivables Contra
	INSERT  #ArTransPostLogDtl
	( PostRun, TransId, FiscalPeriod, EntryNum, [Grouping],
	Amount, Transdate, PostDate, Descr, SourceCode, Reference,DistCode,
	GlAcct , DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
	, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn )  
	SELECT @PostRun, h.RcptHeaderID, h.GlPeriod, 10000,990
	,-(d.PmtAmt + d.[Difference]),h.PmtDate, @WrkStnDate,SubString(d.InvcNum + ' / ' + h.DepositID,1,30),'AR',h.CustId,a.DistCode,
	c.GLAcctDepositReceivables ,
	CASE WHEN (-(d.PmtAmt + d.[Difference])<0)THEN 0 ELSE ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) END,
	CASE WHEN (-(d.PmtAmt + d.[Difference])<0) THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) ELSE 0 END,
	h.FiscalYear,d.RcptDetailID,d.InvcNum,-1,
	CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END,
	CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase THEN 1.0 ELSE a.ExchRate END,
	CASE WHEN (-(d.PmtAmtFgn + d.[DifferenceFgn])<0) THEN 0 ELSE 
		CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase 
			THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) 
			ELSE ABS(d.PmtAmtFgn + d.[DifferenceFgn]) END END,
	CASE WHEN (-(d.PmtAmtFgn + d.[DifferenceFgn])<0) THEN 
		CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase 
			THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) 
			ELSE ABS(d.PmtAmtFgn + d.[DifferenceFgn]) END ELSE 0 END
	FROM dbo.tblArCashRcptHeader h
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	INNER JOIN(SELECT CustId, InvcNum, MIN(DistCode) DistCode, MIN(ExchRate) ExchRate
		FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
		GROUP BY CustId, InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum
	Inner Join dbo.tblArDistCode c ON c.DistCode=a.DistCode 
	Left Join dbo.tblGlAcctHdr g ON c.GLAcctDepositReceivables = g.AcctId 
	WHERE h.CustId IS NOT NULL

	INSERT #ArTransPostLogDtl
	( PostRun, TransId, FiscalPeriod, EntryNum, [Grouping]
	,Amount, Transdate, PostDate, Descr, SourceCode, Reference,DistCode
	,GlAcct , DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
	,CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn )  
	SELECT @PostRun, h.RcptHeaderID, h.GlPeriod, 10000,990
	,d.PmtAmt + d.[Difference],h.PmtDate, @WrkStnDate,SubString(d.InvcNum + ' / ' + h.DepositID,1,30),'AR',h.CustId,a.DistCode
	,c.GLAcctDepositReceivablesContra ,
	CASE WHEN(d.PmtAmt + d.[Difference]<0) THEN 0 ELSE ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) END, 
	CASE WHEN (d.PmtAmt + d.[Difference]<0) THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) ELSE 0 END,
	h.FiscalYear,d.RcptDetailID,d.InvcNum,-1,
	CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END,
	CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase THEN 1.0 ELSE a.ExchRate END,
	CASE WHEN (d.PmtAmtFgn + d.[DifferenceFgn]<0) THEN 0 ELSE 
		CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase 
			THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) 
			ELSE ABS(d.PmtAmtFgn + d.[DifferenceFgn]) END END,
	CASE WHEN (d.PmtAmtFgn + d.[DifferenceFgn]<0) THEN 
		CASE WHEN CASE WHEN @MCYN = 1 AND @ArGlYn = 1 THEN g.CurrencyID ELSE @CurrBase END = @CurrBase 
			THEN ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn])/a.ExchRate,@PrecCurr)) 
			ELSE ABS(d.PmtAmtFgn + d.[DifferenceFgn]) END ELSE 0 END
	FROM dbo.tblArCashRcptHeader h
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	INNER JOIN (SELECT CustId, InvcNum, MIN(DistCode) DistCode, MIN(ExchRate) ExchRate
		FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
		GROUP BY CustId, InvcNum ) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum
	Inner Join tblArDistCode c ON c.DistCode=a.DistCode 
	Left Join dbo.tblGlAcctHdr g ON c.GLAcctDepositReceivables = g.AcctId 
	WHERE h.CustId IS NOT NULL
		
	--Cash receipts that are applied to pro forma invoice
	--GL entries for Customer Deposit
	INSERT #ArTransPostLogDtl
	( PostRun, TransId, FiscalPeriod, EntryNum, [Grouping]
	,Amount, Transdate, PostDate, Descr, SourceCode, Reference,DistCode
	,GlAcct , DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
	,CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn )  
	SELECT @PostRun, h.RcptHeaderID, h.GlPeriod, 10000,990
	,-(CASE WHEN a.CustId IS NOT NULL THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) ELSE d.PmtAmt + d.[Difference] END)
	,h.PmtDate, @WrkStnDate,SubString(d.InvcNum + ' / ' + h.DepositID,1,30),'AR',h.CustId,d.DistCode
	,@CustDepositAcct ,
	CASE WHEN (-(d.PmtAmt + d.[Difference])<0) THEN 0 ELSE ABS(CASE WHEN a.CustId IS NOT NULL THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) ELSE d.PmtAmt + d.[Difference] END) END,
	CASE WHEN (-(d.PmtAmt + d.[Difference])<0) THEN ABS(CASE WHEN a.CustId IS NOT NULL THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) ELSE d.PmtAmt + d.[Difference] END) ELSE 0 END
	,FiscalYear,d.RcptDetailID,d.InvcNum,-1,
	@CurrBase, 1.0,CASE WHEN (-(d.PmtAmt + d.[Difference])<0) THEN 0 ELSE ABS(CASE WHEN a.CustId IS NOT NULL THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) ELSE d.PmtAmt + d.[Difference] END) END,
	CASE WHEN (-(d.PmtAmt + d.[Difference])<0) THEN ABS(CASE WHEN a.CustId IS NOT NULL THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) ELSE d.PmtAmt + d.[Difference] END) ELSE 0 END
	FROM dbo.tblArCashRcptHeader h
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
	INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
	LEFT JOIN (SELECT CustId, InvcNum, MIN(ExchRate) ExchRate
		FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
		GROUP BY CustId, InvcNum ) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum
	WHERE h.CustId IS NOT NULL 

	--Cash
	INSERT #ArTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate
		, PostDate, Descr, SourceCode, Reference, DistCode, GlAcct
		, DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine
		, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)       
	SELECT @PostRun, hid, GlPeriod, 100000, 991, PmtAmt, PmtDate
		, @WrkStnDate, SubString(InvcNum + ' / ' + DePositID, 1, 30)
		, 'AR', Coalesce(CustId, InvcNum), #Temp2.DistCode, GlAcctDebit
		, CASE WHEN PmtAmt > 0
				THEN ABS(PmtAmt) ELSE 0 END
		, CASE WHEN PmtAmt < 0
				THEN ABS(PmtAmt) ELSE 0 END
		, FiscalYear, DID, InvcNum, -1
		, CurrencyDebitAcct
		, CASE WHEN CurrencyDebitAcct = @CurrBase THEN 1.0 ELSE ExchRate END
		, CASE WHEN CurrencyDebitAcct = @CurrBase 
			THEN (CASE WHEN PmtAmt > 0  
				THEN ABS(PmtAmt) ELSE 0 
				END) 
			ELSE (CASE WHEN PmtAmtFgn > 0 
				THEN ABS(PmtAmtFgn) ELSE 0 
				END) 
		END
		, CASE WHEN CurrencyDebitAcct = @CurrBase 
			THEN (CASE WHEN PmtAmt < 0 
				THEN ABS(PmtAmt) ELSE 0 
				END) 
			ELSE (CASE WHEN PmtAmtFgn < 0 
				THEN ABS(PmtAmtFgn) ELSE 0 
				END) 
			END
	FROM #Temp2
	WHERE PmtAmtFgn <> 0


	--Discount
	INSERT #ArTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,   
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)       
	SELECT @PostRun, hid, GlPeriod, 100000, 992, [Difference]
		, PmtDate, @WrkStnDate,SubString(InvcNum + ' / ' + DePositID,1,30)
		, 'AR', Coalesce(CustId, InvcNum), #Temp2.DistCode, @GlAcctDisc
		, CASE WHEN [Difference] > 0
			THEN ABS([Difference]) ELSE 0 END
		, CASE WHEN [Difference] < 0
			THEN ABS([Difference]) ELSE 0 END
		, FiscalYear, DID, InvcNum, -1
		, @CurrBase, 1.0
		, CASE WHEN [Difference] > 0
			THEN ABS([Difference]) ELSE 0 END
		, CASE WHEN [Difference] < 0
			THEN ABS([Difference]) ELSE 0 END
	FROM #Temp2
	WHERE [Difference] <> 0


	--AR
	INSERT #ArTransPostLogDtl
		(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,
		PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
		DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
		CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)               
	SELECT @PostRun, hid, GlPeriod, 100000, 993, -1 * (PmtAmt + [Difference] - ISNULL(CalcGainLoss,0))
		, PmtDate, @WrkStnDate, SubString(InvcNum + ' / ' + DepositID,1,30)
		, 'AR', Coalesce(CustId, InvcNum), #Temp2.DistCode
		, GLAcctReceivables
		, CASE WHEN -1*(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) > 0
			THEN ABS(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) ELSE 0 END
		, CASE WHEN -1*(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) < 0
			THEN ABS(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) ELSE 0 END
		, FiscalYear, DID, InvcNum, -1
		, CurrencyRcvAcct, CASE WHEN CurrencyRcvAcct = @CurrBase THEN 1 WHEN CurrencyRcvAcct <> @CurrBase AND CalcGainLoss <> 0 
			THEN InvcExchRate ELSE ExchRate END
		, CASE WHEN CurrencyRcvAcct = @CurrBase THEN (CASE WHEN -1*(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) > 0  
			THEN ABS(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) ELSE 0 END) ELSE (CASE WHEN -1 * (PmtAmtFgn  + [DifferenceFgn]) > 0
			THEN ABS(PmtAmtFgn + [DifferenceFgn]) ELSE 0 END) END 
		, CASE WHEN CurrencyRcvAcct = @CurrBase THEN (CASE WHEN -1*(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) < 0  
			THEN ABS(PmtAmt + [Difference] - ISNULL(CalcGainLoss,0)) ELSE 0 END) ELSE (CASE WHEN -1 * (PmtAmtFgn  + [DifferenceFgn]) < 0
			THEN ABS(PmtAmtFgn + [DifferenceFgn] ) ELSE 0 END) END   
	FROM #Temp2
	WHERE InvcType = 1 AND (PmtAmtFgn <> 0 OR [DifferenceFgn] <> 0) --Regular invoice only


	IF @MCYN = 1
	BEGIN
		--process gains/losses when MC is enabled
		Declare @GlDescr nvarchar(30)           
		SET @GlDescr = 'Realized Gains/Losses'

		CREATE TABLE [#tmpArTransPostGainLoss] 
		(
			[PostRun] pPostRun NULL ,
			[Counter] [int] IDENTITY (1, 1) NOT NULL ,
			[GlPeriod] [smallint] NULL ,
			[TransId] pTransId NULL ,
			[EntryNum] [int] NULL ,
			[Grouping] [smallint] NULL ,
			[Amount] [pDecimal],
			[TransDate] [datetime] NULL ,
			[DistCode] [nvarchar] (6) NULL ,
			[GlAcct] [nvarchar] (40) NULL ,
			[DR] [pDecimal] NULL,
			[CR] [pDecimal] NULL,
			[DRFgn] [pDecimal] NULL,
			[CRFgn] [pDecimal] NULL,
			[Year] [smallint] NULL ,
			[LinkID] [nvarchar] (15) NULL ,
			[LinkIDSub] [nvarchar] (15) NULL ,
			[LinkIDSubLine] [int] NULL,
			[TransCurrencyId] [pCurrency] NULL,  --currencyid for trans/pmt
			[ExchRate] pDecimal NULL
		)

		--Gain/Loss for payments that apply to existing pro forma invoice
		--Gain/Loss entries
		INSERT #tmpArTransPostGainLoss
			(PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, Right(Cast(h.RcptHeaderId as nvarchar), 8), h.GlPeriod, 100000, 301
			, ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]), h.PmtDate
			, d.DistCode, CASE WHEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) > 0 THEN t.RealLossAcct ELSE t.RealGainAcct END
			, CASE WHEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) > 0 THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) ELSE 0 END
			, CASE WHEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) > 0 THEN 0 ELSE ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference])) END
			, CASE WHEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) > 0 THEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) ELSE 0 END
			, CASE WHEN ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) > 0 THEN 0 ELSE ABS(ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference])) END
			, h.FiscalYear, d.RcptDetailID, d.InvcNum, -6, @CurrBase, 1.0
		FROM dbo.tblArCashRcptHeader h
			INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID AND d.InvcType=5
			INNER JOIN #PostTransList b on h.RcptHeaderID = b.TransId
			INNER JOIN(SELECT CustId, InvcNum, MIN(ExchRate) ExchRate
				FROM dbo.tblArOpenInvoice WHERE RecType =5 AND AmtFgn>0
				GROUP BY CustId, InvcNum) a ON h.CustId = a.CustId AND d.InvcNum = a.InvcNum 
			LEFT JOIN #GainLossAccounts t ON h.CurrencyId = t.CurrencyId
		WHERE ROUND((d.PmtAmtFgn + d.[DifferenceFgn]) / a.ExchRate, @PrecCurr) - (d.PmtAmt + d.[Difference]) <> 0

		--Gain/Loss for payments
		INSERT #tmpArTransPostGainLoss
			(PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
			DistCode, GlAcct, DR, CR, DRFgn, CRFgn, [Year], LinkID, LinkIDSub, LinkIDSubLine,TransCurrencyID, ExchRate)
		SELECT @PostRun, Right(Cast(h.RcptHeaderId as nvarchar), 8), h.GlPeriod, 100000, 300, d.CalcGainLoss, h.PmtDate
			, d.DistCode, d.GLAcctGainLoss
			, CASE WHEN d.CalcGainLoss > 0 THEN 0 ELSE Abs(d.CalcGainLoss) END
			, CASE WHEN d.CalcGainLoss < 0 THEN 0 ELSE Abs(d.CalcGainLoss) END
			, CASE WHEN d.CalcGainLoss > 0 THEN 0 ELSE Abs(d.CalcGainLoss) END
			, CASE WHEN d.CalcGainLoss < 0 THEN 0 ELSE Abs(d.CalcGainLoss) END
			, h.FiscalYear, d.RcptDetailID, d.InvcNum, -6, @CurrBase, 1.0
		FROM dbo.tblArCashRcptHeader h 
		INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
		INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
		WHERE d.CalcGainLoss <> 0


		--conditionally include Gain/Loss Detail or Summary in the post logs
		IF @PostGainLossDtl = 1 
		BEGIN
			INSERT #ArTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				DR, CR, FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, TransId, GlPeriod, EntryNum, [Grouping], Amount, Transdate,  
					@WrkStnDate, @GlDescr, 'G0', CASE [Grouping] WHEN 301 THEN 'Dep Gain/Loss' ELSE 'AR Gain/Loss' END, DistCode, GlAcct,
					DR, CR, [Year], LinkID, LinkIDSub, LinkIDSubLine,
					TransCurrencyId, ExchRate, DRFgn, CRFgn
				FROM #tmpArTransPostGainLoss
		END
		ELSE
		BEGIN
			INSERT #ArTransPostLogDtl
				(PostRun, TransId, FiscalPeriod, EntryNum, [Grouping], Amount, Transdate,  
				PostDate, Descr, SourceCode, Reference, DistCode, GlAcct,
				FiscalYear, LinkID, LinkIDSub, LinkIDSubLine,
				CurrencyId, ExchRate, DR, CR, DebitAmtFgn, CreditAmtFgn)
			Select PostRun, 100000, GlPeriod, 100000, [Grouping], Sum(Amount), @WrkStnDate
					, @WrkStnDate, @GlDescr, 'G0', CASE [Grouping] WHEN 301 THEN 'Dep Gain/Loss' ELSE 'AR Gain/Loss' END, DistCode, GlAcct
					, [Year], NULL, NULL, -6
					, TransCurrencyId, ExchRate
					, Case When Sum(DR - CR) > 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DR - CR) <= 0 Then abs(Sum(DR - CR)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) > 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
					, Case When Sum(DRFgn - CRFgn) <= 0 Then abs(Sum(DRFgn - CRFgn)) Else 0 End
				FROM #tmpArTransPostGainLoss 
				GROUP BY PostRun, TransCurrencyID, ExchRate, [Year], [GlPeriod], DistCode, GlAcct, [Grouping]
		END
	END

	--populate the GL Log table
	IF (@ArGlDetailYn = 0)
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, Sum(Amount), 'AR'
			, CASE WHEN [Grouping] = 993 THEN @ARDescr
				WHEN [Grouping] = 991 THEN @PaymentDescr
				WHEN [Grouping] = 992 THEN @DiscountDescr 
				WHEN [Grouping] = 990 THEN @DepositDescr
				ELSE @UnknownDescr END
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS [DebitAmount]
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END AS [CreditAmount]
			, CASE WHEN SUM(Amount) > 0 THEN SUM(Amount) ELSE 0 END AS [DebitAmountFgn]
			, CASE WHEN SUM(Amount) < 0 THEN ABS(SUM(Amount)) ELSE 0 END AS [CreditAmountFgn]
			, 'AR', @WrkStnDate, @WrkStnDate, @CurrBase, 1.0, @CompId
		FROM #ArTransPostLogDtl 
		GROUP BY PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAcct 
		ORDER BY PostRun, FiscalYear,  FiscalPeriod,  [Grouping]
	ELSE
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId
			, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, (DebitAmtFgn + CreditAmtFgn) AmountFgn
			, Reference, Descr
			, Cast(DR as decimal(28, 10)) DebitAmount
			, Cast(CR as decimal(28, 10)) CreditAmount
			, DebitAmtFgn, CreditAmtFgn 
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, @CompId
			, LinkID, LinkIDSub, LinkIDSubLine
			FROM #ArTransPostLogDtl 

	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod]
		, [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
		, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])
	SELECT h.FiscalYear, h.GlPeriod
		, 0
		, Sum(CASE WHEN CustID IS NULL THEN 0 ELSE (d.PmtAmt + d.[Difference] - d.CalcGainLoss) END)
		, Sum(CASE WHEN CustID IS NULL THEN (d.PmtAmt + d.[Difference] - d.CalcGainLoss) ELSE 0 END)
		, h.CurrencyId
		, 0
		, Sum(CASE WHEN CustID IS NULL THEN 0 ELSE d.PmtAmtFgn + d.[DifferenceFgn] END)
		, Sum(CASE WHEN CustID IS NULL THEN d.PmtAmtFgn + d.[DifferenceFgn] ELSE 0 END)
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	GROUP BY h.CurrencyId, h.FiscalYear, h.GlPeriod

	--update the payment summary log table
	INSERT INTO #PaymentSummary ([FiscalYear], [FiscalPeriod], [BankId], [PmtMethodId]
		, [Description], [PaymentType], [PaymentAmount], [CurrencyId], [PaymentAmountFgn])
	SELECT h.FiscalYear, h.GlPeriod
		, pm.BankId, h.PmtMethodId, pm.[Desc], pm.PmtType, Sum(d.PmtAmt)
		, ISNULL(br.[CurrencyID], h.[CurrencyID])
		, Sum(CASE WHEN ISNULL(br.[CurrencyID], h.[CurrencyID]) = h.[CurrencyID] THEN d.PmtAmtFgn ELSE d.PmtAmt END)
	FROM dbo.tblArCashRcptHeader h 
	INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID 
	INNER JOIN dbo.tblArPmtMethod pm ON h.PmtMethodId = pm.PmtMethodID
	INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId 
	LEFT JOIN dbo.tblSmBankAcct br ON pm.BankID = br.BankID 
	GROUP BY ISNULL(br.[CurrencyID], h.[CurrencyID]), h.FiscalYear, h.GlPeriod, pm.BankId, h.PmtMethodId, pm.[Desc], pm.PmtType


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCashReceiptPost_BuildLog_proc';


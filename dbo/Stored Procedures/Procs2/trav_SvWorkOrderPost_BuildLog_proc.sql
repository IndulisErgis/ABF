
CREATE PROCEDURE dbo.trav_SvWorkOrderPost_BuildLog_proc
AS
BEGIN TRY
	

DECLARE	@PostRun pPostRun
	, @MCYn bit
	, @GlYn bit
	, @PostDtlYn bit
	, @CurrBase pCurrency
	, @PrecCurr smallint
	, @CompId [sysname]     
	, @WrkStnDate datetime
	, @SourceCode nvarchar(2)

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @MCYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @GlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'GlYn'
	SELECT @PostDtlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlYn'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @SourceCode = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'SourceCode'

	IF @PostRun IS NULL OR @MCYn IS NULL OR @GlYn IS NULL   OR @PostDtlYn IS NULL 
		 OR @CurrBase IS NULL OR @WrkStnDate IS NULL 		
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #TransPostLog 
	(
		[Counter] int Not Null Identity(1, 1), 
		[PostRun] pPostRun Not Null, 
		[TransId] pTransId Null, 
		[EntryNum] int Null, 
		[Grouping] smallint Null, 
		[TransDate] datetime Null, 
		[PostDate] datetime Null, 
		[Descr] nvarchar(30) Null, 
		[SourceCode] nvarchar(2) Null, 
		[Reference] nvarchar(15) Null, 
		[DistCode] pDistCode Null,
		[GlAcct] pGlAcct Null, 
		[CreditAmount] pDecimal Null, 
		[DebitAmount] pDecimal Null, 
		[FiscalPeriod] smallint Null, 
		[FiscalYear] smallint Null, 
		[LinkID] nvarchar(255) Null, 
		[LinkIDSub] nvarchar(255) Null,	
		[CurrencyId] pCurrency Null, 
		[ExchRate] pDecimal Null Default(1), 
		[AmountFgn] pDecimal Null Default(0), 
		[DebitAmtFgn] pDecimal Null Default(0), 
		[CreditAmtFgn] pDecimal Null Default(0)
	)


	SELECT h.FiscalYear , h.FiscalPeriod , h.DistCode, h.TransId, h.TransType	,h.BillToID CustID, h.InvoiceNumber,h.WorkOrderID
		, CASE WHEN dbo.tblGlAcctHdr.CurrencyId <> @CurrBase THEN  h.CurrencyId ELSE @CurrBase END CurrencyId
		, CASE WHEN dbo.tblGlAcctHdr.CurrencyId <> @CurrBase THEN h.ExchRate ELSE 1 END ExchRate
		, h.InvoiceDate,h.TaxSubtotal,h.NonTaxSubtotal, h.SalesTax 	,h.TaxAmtAdj,h.TotCost, h.TaxSubtotalFgn,h.NonTaxSubtotalFgn
		,h.SalesTaxFgn,h.TaxAmtAdjFgn, d.GLAcctCredit,d.GLAcctDebit,d.GLAcctSales, d.CostExt, d.CostExtFgn,d.PriceExt, d.PriceExtFgn, d.EntryNum 
		, d.[Description] , d.WorkOrderTransID,d.WorkOrderTransType, wt.FiscalPeriod [TransFiscalYear],wt.FiscalPeriod [TransFiscalPeriod], wt.TransDate
		,dbo.tblArDistCode.GLAcctReceivables, dbo.tblArDistCode.GLAcctFreight, dbo.tblArDistCode.GLAcctMisc, ISNULL(k.DropShipYn,0) AS DropShipYn, dis.DispatchNo
	INTO #Temp1 
	FROM (dbo.tblSvInvoiceHeader h
		 INNER JOIN #PostTransList l ON h.TransId = l.TransId
		 INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
		 LEFT JOIN tblSvWorkOrderTrans	Wt on  d.WorkOrderTransID = wt.ID
		 INNER JOIN dbo.tblArDistCode  ON  h.DistCode = dbo.tblArDistCode.DistCode)
		 LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON d.DispatchID = dis.ID
		 LEFT JOIN dbo.tblGlAcctHdr ON  dbo.tblArDistCode.GLAcctReceivables =  dbo.tblGlAcctHdr.AcctId 
		 LEFT JOIN dbo.tblSmTransLink k ON Wt.LinkSeqNum = k.SeqNum
	WHERE h.VoidYN =0 AND h.PrintStatus<>3
	ORDER BY h.FiscalYear,h.FiscalPeriod,h.TransId


	--Freight/Misc
	INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	SELECT @PostRun, FiscalPeriod,FiscalYear, TransID,  InvoiceDate, @WrkStnDate, EntryNum 
		,CASE WHEN WorkOrderTransType=2 THEN 30
			 WHEN WorkOrderTransType=3 THEN 40 END
		,substring(ISNULL(InvoiceNumber + ' / ','') + ISNULL( [Description],''), 1, 30)
		,'SD',CustID,DistCode
		,CASE WHEN WorkOrderTransType=2 THEN GLAcctFreight
			 WHEN WorkOrderTransType=3 THEN GLAcctMisc END
		, -1* SIGN(TransType) * PriceExt
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN 0  ELSE ABS(PriceExt) END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN 0  ELSE ABS(PriceExt) END
		,DispatchNo
	FROM #Temp1
	WHERE WorkOrderTransType =2 OR  WorkOrderTransType =3
	
	

	--Part/Labor/Manual 

	--Inventory/Payroll
	INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn, LinkIDSub)   
	SELECT @PostRun, FiscalPeriod,FiscalYear, TransID, TransDate, @WrkStnDate, EntryNum 
		,CASE WHEN WorkOrderTransType=0 THEN 10
			 WHEN WorkOrderTransType=1 THEN 20 
			 WHEN WorkOrderTransType IS NULL THEN 40 END
		,substring(ISNULL(InvoiceNumber + ' / ','') +ISNULL( [Description],''), 1, 30)
		,'SD', CustID, DistCode, GLAcctCredit
		,-1* SIGN(TransType) * CostExt
		,CASE WHEN  SIGN(TransType) * CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * CostExt > 0 THEN 0  ELSE ABS(CostExt) END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  SIGN(TransType) * CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * CostExt > 0 THEN 0  ELSE ABS(CostExt) END
		,DispatchNo
		FROM #Temp1
		WHERE (WorkOrderTransType =0 OR  WorkOrderTransType =1 OR WorkOrderTransType IS NULL) AND DropShipYn = 0 -- skip for drop shipped
	

		--Cost of Sales
	INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	SELECT @PostRun,FiscalPeriod,FiscalYear, TransID, InvoiceDate, @WrkStnDate, EntryNum ,50
		,substring(ISNULL(InvoiceNumber + ' / ','') +ISNULL( [Description],''), 1, 30),'SD', CustID, DistCode, GLAcctDebit
		, SIGN(TransType) * CostExt
		,CASE WHEN  SIGN(TransType) * CostExt < 0 THEN ABS(CostExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * CostExt < 0 THEN 0  ELSE ABS(CostExt) END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  SIGN(TransType) * CostExt < 0 THEN ABS(CostExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * CostExt < 0 THEN 0  ELSE ABS(CostExt) END
		,DispatchNo
		FROM #Temp1
		WHERE (WorkOrderTransType =0 OR  WorkOrderTransType =1 OR WorkOrderTransType IS NULL) AND DropShipYn = 0 -- skip for drop shipped

		--Line Item Sales:
	INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn, LinkIDSub)   
	SELECT @PostRun, FiscalPeriod,FiscalYear, TransID, InvoiceDate, @WrkStnDate, EntryNum 
		,60
		,substring(ISNULL(InvoiceNumber + ' / ','') +ISNULL( [Description],''), 1, 30)
		,'SD',CustID,DistCode
		,GLAcctSales
		,-1* SIGN(TransType) * PriceExt
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN 0  ELSE ABS(PriceExt) END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,CASE WHEN  SIGN(TransType) * PriceExt > 0 THEN 0  ELSE ABS(PriceExt) END
		,DispatchNo
		FROM #Temp1
		WHERE WorkOrderTransType =0 OR  WorkOrderTransType =1 OR WorkOrderTransType IS NULL



	--Tax Locations
	Create Table #zzTax
	(
		TransId pTransId, 
		WorkOrderID bigint, 
		FiscalYear smallint, 
		FiscalPeriod smallint, 
		TaxAmount pDecimal Null,
		InvcDate datetime,
		TaxLocID pTaxLoc Null,
		CustID pCustId Null, 
		DistCode pDistCode Null, 
		LiabilityAcct pGlAcct Null,
		TransType int null,
		InvoiceNumber pInvoiceNum Null
	)
                        
	--tax detail                                         
	INSERT INTO #zzTax (TransId, WorkOrderID, FiscalYear, FiscalPeriod, TaxAmount
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, TransType,InvoiceNumber)
		SELECT h.TransId, WorkOrderID, h.FiscalYear, h.FiscalPeriod
			,  TaxAmt
			, h.InvoiceDate, t.TaxLocID, h.BillToID , h.DistCode, t.LiabilityAcct,h.TransType,h.InvoiceNumber
		FROM dbo.tblSvInvoiceHeader h 
		INNER JOIN dbo.tblSvInvoiceTax t ON h.TransId = t.TransId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE VoidYN=0 AND t.TaxAmt <> 0 AND h.PrintStatus<>3
			
	--tax adjustments
	INSERT INTO #zzTax (TransId, WorkOrderID, FiscalYear, FiscalPeriod, TaxAmount
		, InvcDate, TaxLocID, CustID, DistCode, LiabilityAcct, TransType,InvoiceNumber)
		SELECT h.TransId,WorkOrderID, h.FiscalYear, h.FiscalPeriod
			,  TaxAmtAdj
			, h.InvoiceDate, h.TaxLocAdj, h.BillToID , h.DistCode, t.GlAcct,h.TransType,h.InvoiceNumber
		FROM dbo.tblSvInvoiceHeader h
		LEFT JOIN dbo.tblSmTaxLoc t on h.TaxLocAdj = t.TaxLocId
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		WHERE  VoidYN=0 AND TaxAmtAdj <> 0 AND h.PrintStatus<>3

	INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)   

		SELECT @PostRun, FiscalPeriod,FiscalYear, TransID, InvcDate, @WrkStnDate, 0,70
		, substring(ISNULL(InvoiceNumber + ' / ','') + 'Sales Tax' + ' / ' + TaxLocID, 1, 30)
		,'SD',CustID,DistCode
		,LiabilityAcct
		,SUM(-1* SIGN(TransType) * TaxAmount)
		,CASE WHEN  SUM(SIGN(TransType) * TaxAmount) > 0 THEN SUM(SIGN(TransType) * TaxAmount) ELSE 0 END
		,CASE WHEN  SUM(SIGN(TransType) *TaxAmount) > 0 THEN 0  ELSE ABS(SUM(SIGN(TransType) *TaxAmount)) END
		,WorkOrderID, @CurrBase, 1
		,CASE WHEN  SUM(SIGN(TransType) * TaxAmount) > 0 THEN SUM(SIGN(TransType) * TaxAmount) ELSE 0 END
		,CASE WHEN  SUM(SIGN(TransType) *TaxAmount) > 0 THEN 0  ELSE ABS(SUM(SIGN(TransType) *TaxAmount)) END

		FROM #zzTax 
		GROUP BY TransId, CustID, DistCode, InvcDate, WorkOrderID, FiscalYear, FiscalPeriod, TaxLocID, LiabilityAcct,TransType,InvoiceNumber
		HAVING SUM(TaxAmount) <> 0

	--AR entry    

	IF @MCYn=1
		BEGIN
			INSERT INTO #TransPostLog    
			(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
			 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
			CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)  
		 
			SELECT @PostRun, FiscalPeriod,FiscalYear, h.TransID, InvoiceDate, @WrkStnDate, 0
			,80
			,h.InvoiceNumber + ' / ' + 'A/R'
			,@SourceCode,h.BillToID,h.DistCode
			,dc.GLAcctReceivables
			,CASE WHEN g.CurrencyId <> @CurrBase THEN  SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn+ TaxAmtAdjFgn)
				ELSE  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) END

			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)  ELSE 0 END
			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN  0 ELSE ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)   END
			,WorkOrderID
			, CASE WHEN g.CurrencyId <> @CurrBase THEN  h.CurrencyId ELSE @CurrBase END CurrencyId
			, CASE WHEN g.CurrencyId <> @CurrBase THEN h.ExchRate ELSE 1 END ExchRate
			,CASE WHEN g.CurrencyId <> @CurrBase THEN
				CASE WHEN  SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn+ TaxAmtAdjFgn) < 0 THEN ABS(TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn+ TaxAmtAdjFgn)  ELSE 0 END
			 ELSE
				CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)  ELSE 0 END
			 END
			,CASE WHEN g.CurrencyId <> @CurrBase THEN
				CASE WHEN  SIGN(TransType) * (TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn+ TaxAmtAdjFgn) < 0 THEN  0 ELSE ABS(TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn+ TaxAmtAdjFgn)   END
			 ELSE
				CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN  0 ELSE ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)   END
			 END
			FROM (dbo.tblSvInvoiceHeader h
			 INNER JOIN #PostTransList l ON h.TransId = l.TransId
			 INNER JOIN dbo.tblArDistCode dc ON  h.DistCode = dc.DistCode)
			 LEFT JOIN dbo.tblGlAcctHdr g ON  dc.GLAcctReceivables =  g.AcctId 
			 WHERE VoidYN=0 AND h.PrintStatus<>3
		END
	ELSE
		BEGIN
		INSERT INTO #TransPostLog    
			(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
			 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
			CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn)  
		 
			SELECT @PostRun, FiscalPeriod,FiscalYear, h.TransID, InvoiceDate, @WrkStnDate, 0
			,80
			,h.InvoiceNumber + ' / ' + 'A/R'
			,@SourceCode,h.BillToID,h.DistCode
			,dc.GLAcctReceivables
			,	 SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) 
			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)  ELSE 0 END
			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN  0 ELSE ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)   END
			,WorkOrderID,@CurrBase,1
			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)  ELSE 0 END
			,CASE WHEN  SIGN(TransType) * (TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj) < 0 THEN  0 ELSE ABS(TaxSubtotal + NonTaxSubtotal + SalesTax+ TaxAmtAdj)   END
			FROM (dbo.tblSvInvoiceHeader h
			 INNER JOIN #PostTransList l ON h.TransId = l.TransId
			 INNER JOIN dbo.tblArDistCode dc ON  h.DistCode = dc.DistCode)
			 WHERE VoidYN=0 AND h.PrintStatus<>3

	END
	
		--SD to PC Link  -- Billing through PC
	 
		SELECT  w.CustID, wt.FiscalYear ,wt.FiscalPeriod ,
		 substring((ISNULL(h.InvoiceNumber + ' / ','') +ISNULL(d.Description,'')),1,30) Description,
		 wt.TransDate, @CurrBase CurrencyId,w.ID WorkOrderId, h.TransType
			,dc.GLAcctWIP, dc.GLAcctAccruedIncome, wt.GLAcctDebit,wt.GLAcctCredit, wt.PriceExt, wt.CostExt, wt.TransType WorkOrderTransType
			, p.Type ProjectType, pd.Billable, pd.FixedFee, dis.DispatchNo
		INTO #tmpPCBilling
		FROM (dbo.tblSvInvoiceHeader h
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		INNER JOIN dbo.tblSvWorkOrder w ON w.ID = h.WorkOrderID
		INNER JOIN dbo.tblPcProjectDetail pd ON w.ProjectDetailID = pd.Id
		INNER JOIN dbo.tblPcProject p ON p.Id= pd.ProjectId
		INNER JOIN dbo.tblSvInvoiceDetail d ON h.TransId = d.TransID 
		INNER JOIN tblSvWorkOrderTrans	Wt on  d.WorkOrderTransID = wt.ID
		INNER JOIN dbo.tblPcDistCode dc ON  pd.DistCode = dc.DistCode
		LEFT JOIN dbo.tblSvWorkOrderDispatch dis ON d.DispatchID = dis.ID)		 
		WHERE h.VoidYN =0 AND h.PrintStatus=3 AND w.BillVia =1 
		

	 
	  -- WIP
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,100
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null, GLAcctWIP
		,PriceExt
		,CASE WHEN  PriceExt > 0 THEN 0 ELSE ABS(PriceExt)  END
		,CASE WHEN   PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  PriceExt > 0 THEN  0 ELSE ABS(PriceExt)   END
		,CASE WHEN   PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE (WorkOrderTransType =0 OR  WorkOrderTransType =1) AND ProjectType =0 AND Billable =1 AND FixedFee =0

		
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,100
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null, GLAcctWIP
		,CostExt
		,CASE WHEN  CostExt > 0 THEN 0 ELSE ABS(CostExt)  END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  CostExt > 0 THEN  0 ELSE ABS(CostExt)   END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE WorkOrderTransType <>0 AND  WorkOrderTransType <>1  AND ProjectType =0 AND Billable =1 AND FixedFee =0


		-- Accrued Income
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,110
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null, GLAcctAccruedIncome
		, -1 * PriceExt
		,CASE WHEN  -1 * PriceExt > 0 THEN 0 ELSE ABS(PriceExt)  END
		,CASE WHEN   -1 * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  -1 * PriceExt > 0 THEN  0 ELSE ABS(PriceExt)   END
		,CASE WHEN   -1 * PriceExt > 0 THEN ABS(PriceExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE (WorkOrderTransType =0 OR  WorkOrderTransType =1)  AND ProjectType =0 AND Billable =1 AND FixedFee =0

		
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn, LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,110
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null, GLAcctAccruedIncome
		,-1 * CostExt
		,CASE WHEN  -1 * CostExt > 0 THEN 0 ELSE ABS(CostExt)  END
		,CASE WHEN   -1 * CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  -1 * CostExt > 0 THEN  0 ELSE ABS(CostExt)   END
		,CASE WHEN   -1 *  CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE (WorkOrderTransType <>0 AND  WorkOrderTransType <>1)  AND ProjectType =0 AND Billable =1 AND FixedFee =0
	
	-- Cost of Sales
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,CASE WHEN ProjectType=1 THEN 100 ELSE 50 END
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null
		, CASE WHEN ProjectType=1 THEN GLAcctWIP ELSE GLAcctDebit END
		,CostExt
		,CASE WHEN  CostExt > 0 THEN 0 ELSE ABS(CostExt)  END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  CostExt > 0 THEN  0 ELSE ABS(CostExt)   END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE WorkOrderTransType =0
	
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,CASE WHEN ProjectType=1 THEN 100 ELSE 50 END
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null
		, GLAcctDebit
		,CostExt
		,CASE WHEN  CostExt > 0 THEN 0 ELSE ABS(CostExt)  END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN  CostExt > 0 THEN  0 ELSE ABS(CostExt)   END
		,CASE WHEN   CostExt > 0 THEN ABS(CostExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE WorkOrderTransType =1

	-- Inventory/Payroll
		INSERT INTO #TransPostLog    
		(PostRun, FiscalPeriod, FiscalYear, TransId, Transdate,PostDate, EntryNum, [Grouping], 
		 Descr, SourceCode, Reference, DistCode, GlAcct,AmountFgn, CreditAmount, DebitAmount, LinkID,
		CurrencyId, ExchRate, CreditAmtFgn, DebitAmtFgn,LinkIDSub)   
	   SELECT @PostRun, FiscalPeriod,FiscalYear, null, TransDate, @WrkStnDate, 0
		,CASE WHEN WorkOrderTransType =0 THEN 10 ELSE 20 END
		,substring(ISNULL( [Description],''), 1, 30)
		,'SD', CustID, Null
		, GLAcctCredit
		,-1 *CostExt
		,CASE WHEN  (-1 *CostExt) > 0 THEN 0 ELSE ABS(CostExt)  END
		,CASE WHEN  (-1 *CostExt) > 0 THEN ABS(CostExt)  ELSE 0 END
		,WorkOrderID,@CurrBase,1
		,CASE WHEN (-1 *CostExt)> 0 THEN  0 ELSE ABS(CostExt)   END
		,CASE WHEN   (-1 *CostExt) > 0 THEN ABS(CostExt)  ELSE 0 END
		,DispatchNo
		FROM #tmpPCBilling
		WHERE WorkOrderTransType =0 OR  WorkOrderTransType =1

	--populate the GL Log table
	IF (@PostDtlYn = 0)
	  BEGIN
	  --Summarize credit/debit entries separately
	  
			--Credit entry
			INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
				, GlAccount, AmountFgn, Reference, [Description]
				, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
				, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)

			SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAcct, -SUM(CreditAmtFgn), 'SD'
				, CASE WHEN [Grouping] = 10 THEN 'Labor'	WHEN [Grouping] = 20 THEN 'Part' WHEN [Grouping] = 30 THEN 'Freight'
					WHEN [Grouping] = 40 THEN 'Misc Charges' WHEN [Grouping] = 50 THEN 'Cost of Sales'
					WHEN [Grouping] = 60 THEN 'Sales' WHEN [Grouping] = 70 THEN 'Sales Tax' WHEN [Grouping] = 80 THEN 'A/R'
					WHEN [Grouping] = 100 THEN 'WIP' WHEN [Grouping] = 110 THEN 'Accrued Income'
					ELSE'Unknown' END
				, 0,	SUM(CreditAmount), 0, SUM(CreditAmtFgn)
				, @SourceCode, @WrkStnDate, @WrkStnDate, CurrencyId, ExchRate, @CompId
			FROM #TransPostLog 
			WHERE CreditAmtFgn <> 0
			GROUP BY FiscalYear, FiscalPeriod, [Grouping],CurrencyId,ExchRate, GlAcct 

			--Debit entry
			INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
				, GlAccount, AmountFgn, Reference, [Description]
				, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
				, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId)

			SELECT @PostRun, FiscalYear, FiscalPeriod, [Grouping], GlAcct, -SUM(CreditAmtFgn), 'SD'
				, CASE WHEN [Grouping] = 10 THEN 'Labor'	WHEN [Grouping] = 20 THEN 'Part' WHEN [Grouping] = 30 THEN 'Freight'
					WHEN [Grouping] = 40 THEN 'Misc Charges' WHEN [Grouping] = 50 THEN 'Cost of Sales'
					WHEN [Grouping] = 60 THEN 'Sales' WHEN [Grouping] = 70 THEN 'Sales Tax' WHEN [Grouping] = 80 THEN 'A/R'
					WHEN [Grouping] = 100 THEN 'WIP' WHEN [Grouping] = 110 THEN 'Accrued Income'
					ELSE'Unknown' END
				, SUM(DebitAmount),	0, SUM(DebitAmtFgn), 0
				, @SourceCode, @WrkStnDate, @WrkStnDate, CurrencyId, ExchRate, @CompId
			FROM #TransPostLog 
			WHERE DebitAmtFgn <> 0
			GROUP BY FiscalYear, FiscalPeriod, [Grouping],CurrencyId,ExchRate, GlAcct 

		END
	ELSE

		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId
			, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, (DebitAmtFgn + CreditAmtFgn) AmountFgn
			, Reference, Descr
			, Cast(DebitAmount as decimal(28,10)) DebitAmount
			, Cast(CreditAmount as decimal(28,10)) CreditAmount
			, DebitAmtFgn, CreditAmtFgn 
			, @SourceCode, PostDate, TransDate, CurrencyId, ExchRate, @CompId
			, LinkID,LinkIDSub, NULL
			FROM #TransPostLog 
			WHERE (CreditAmtFgn +DebitAmtFgn) <> 0
			


	--update the transaction summary log table
	INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod]
		, [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
		, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])
	SELECT FiscalYear, FiscalPeriod
		, SUM(SIGN(TransType)*(TaxSubtotal+NonTaxSubtotal+SalesTax+TaxAmtAdj))
		, 0, 0
		, CurrencyId
		, SUM(SIGN(TransType)*(TaxSubtotalFgn+NonTaxSubtotalFgn+SalesTaxFgn+TaxAmtAdjFgn))
		, 0, 0
	FROM dbo.tblSvInvoiceHeader h
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE VoidYN=0 AND h.PrintStatus<>3
	GROUP BY FiscalYear, FiscalPeriod, CurrencyId


	IF NOT EXISTS ( SELECT FiscalYear FROM  #TransactionSummary)
	BEGIN
		INSERT INTO #TransactionSummary ([FiscalYear], [FiscalPeriod], [TransAmt], [RcptAmtApplied], [RcptAmtUnapplied]
			, [CurrencyId], [TransAmtFgn], [RcptAmtAppliedFgn], [RcptAmtUnappliedFgn])

		SELECT FiscalYear, FiscalPeriod	, 0	, 0, 0
			, CurrencyId, 0	, 0, 0
		FROM dbo.tblSvInvoiceHeader h
		INNER JOIN #PostTransList l ON h.TransId = l.TransId
		INNER JOIN dbo.tblSvWorkOrder w ON h.WorkOrderID = w.ID
		WHERE VoidYN=0 AND w.BillVia =1
		GROUP BY FiscalYear, FiscalPeriod, CurrencyId
	END
	
 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SvWorkOrderPost_BuildLog_proc';


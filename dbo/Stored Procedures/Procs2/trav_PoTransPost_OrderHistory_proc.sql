
CREATE PROCEDURE dbo.trav_PoTransPost_OrderHistory_proc
AS
BEGIN TRY	
	
	DECLARE @PostRun nvarchar(14)

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	CREATE TABLE #TempProject
	( 
		TransId pTransId NOT NULL,
		EntryNum int NOT NULL,
		ProjId varchar(10) NULL,
		PhaseId varchar(10) NULL,
		TaskId varchar(10) NULL,
		CustId varchar(10) NULL,
		ProjName varchar(30) NULL,
		PhaseName varchar(30) NULL,
		TaskName varchar(30) NULL,
		PRIMARY KEY CLUSTERED ([TransId], [EntryNum])
	)
	
	--direct project
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId, CustId, ProjName, PhaseName, TaskName)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId, p.CustId, p.[Description], s.[Description], j.[Description]
	FROM #CompletedTransactions l INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblPcProjectDetail j ON d.ProjectDetailId = j.Id 
		INNER JOIN dbo.trav_PcProject_view p ON j.ProjectId = p.Id
		LEFT JOIN dbo.tblPcPhase s ON j.PhaseId = s.PhaseId
	--project link		
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId, CustId, ProjName, PhaseName, TaskName)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId, p.CustId, p.[Description], s.[Description], j.[Description]
	FROM #CompletedTransactions l INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblSmTransLink k ON d.LinkSeqNum = k.SeqNum 
		INNER JOIN dbo.tblPcTrans t ON k.SourceId = t.Id
		INNER JOIN dbo.tblPcProjectDetail j ON t.ProjectDetailId = j.Id 
		INNER JOIN dbo.trav_PcProject_view p ON j.ProjectId = p.Id	
		LEFT JOIN dbo.tblPcPhase s ON j.PhaseId = s.PhaseId
	WHERE k.TransLinkType = 0 AND k.SourceType = 3 AND k.DestType = 2 --Link between Project and PO order
		AND k.SourceStatus <> 2 AND k.DestStatus <> 2 --link is not broken

	INSERT INTO dbo.tblPoHistHeader (PostRun, TransId, BatchId, TransType, LocId, VendorId, Notes, DistCode, 
		TermsCode, TransDate, TaxGrpID, TaxableYn, PrintStatus, PrintDate, ReqShipDate, OrderedBy, ReceivedBy, FOB, 
		CurrencyID, ExchRate, ShipToID, ShipToAttn, ShipToName, ShipToAddr1, ShipToAddr2, ShipToCity, ShipToRegion, 
		ShipToCountry, ShipToPostalCode, ShipVia, MemoTaxable, MemoNonTaxable, MemoSalesTax, MemoFreight, MemoMisc, 
		MemoDisc, MemoPrepaid, CheckDate, MemoTaxableFgn, MemoNonTaxableFgn, MemoSalesTaxFgn, MemoFreightFgn, 
		MemoMiscFgn, MemoDiscFgn, MemoPrepaidFgn, MemoCheckNo, MemoDueDate1, MemoDueDate2, MemoDueDate3, MemoPmtAmt1, 
		MemoPmtAmt2, MemoPmtAmt3, MemoPmtAmt1Fgn, MemoPmtAmt2Fgn, MemoPmtAmt3Fgn, MemoTaxClassFreight, MemoTaxClassMisc, 
		MemoTaxLocID1, MemoTaxAmt1, MemoTaxAmt1Fgn, MemoTaxLocID2, MemoTaxAmt2, MemoTaxAmt2Fgn, MemoTaxLocID3, 
		MemoTaxAmt3, MemoTaxAmt3Fgn, MemoTaxLocID4, MemoTaxAmt4, MemoTaxAmt4Fgn, MemoTaxLocID5, MemoTaxAmt5, 
		MemoTaxAmt5Fgn,HdrRef,DropShipYn,CF,
		GroupId,RequestedDate,RequestedBy,ApprovedDate,ApprovedBy,RequestStatus,ExpReceiptDate)
	SELECT @PostRun,h.TransId, h.BatchId, h.TransType, h.LocId, h.VendorId, h.Notes, h.DistCode, h.TermsCode, 
		h.TransDate, h.TaxGrpID, h.TaxableYn, h.PrintStatus, h.PrintDate, h.ReqShipDate, h.OrderedBy, h.ReceivedBy, 
		h.FOB, h.CurrencyID, h.ExchRate, h.ShipToID, h.ShipToAttn, h.ShipToName, h.ShipToAddr1, h.ShipToAddr2, 
		h.ShipToCity, h.ShipToRegion, h.ShipToCountry, h.ShipToPostalCode, h.ShipVia, h.MemoTaxable, h.MemoNonTaxable, 
		h.MemoSalesTax, h.MemoFreight, h.MemoMisc, h.MemoDisc, h.MemoPrepaid, h.CheckDate, h.MemoTaxableFgn, 
		h.MemoNonTaxableFgn, h.MemoSalesTaxFgn, h.MemoFreightFgn, h.MemoMiscFgn, h.MemoDiscFgn, h.MemoPrepaidFgn, 
		h.MemoCheckNo, h.MemoDueDate1, h.MemoDueDate2, h.MemoDueDate3, h.MemoPmtAmt1, h.MemoPmtAmt2, h.MemoPmtAmt3, 
		h.MemoPmtAmt1Fgn, h.MemoPmtAmt2Fgn, h.MemoPmtAmt3Fgn, h.MemoTaxClassFreight, h.MemoTaxClassMisc, 
		h.MemoTaxLocID1, h.MemoTaxAmt1, h.MemoTaxAmt1Fgn, h.MemoTaxLocID2, h.MemoTaxAmt2, h.MemoTaxAmt2Fgn, 
		h.MemoTaxLocID3, h.MemoTaxAmt3, h.MemoTaxAmt3Fgn, h.MemoTaxLocID4, h.MemoTaxAmt4, h.MemoTaxAmt4Fgn, 
		h.MemoTaxLocID5, h.MemoTaxAmt5, h.MemoTaxAmt5Fgn,h.HdrRef,h.DropShipYn, h.CF,
		r.GroupId,r.RequestedDate,r.RequestedBy,r.ApprovedDate,r.ApprovedBy,r.[Status],h.ExpReceiptDate
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransHeader h ON i.TransID = h.TransId
			LEFT JOIN dbo.tblPoTransRequest r ON h.TransID = r.TransId
	--Add a new field GLAcctAccrual (Modified for PO Extending PO Accrual Functionality)
	INSERT INTO dbo.tblPoHistDetail (PostRun, TransID, EntryNum, QtyOrd, UnitCost, UnitCostFgn, ExtCost, ExtCostFgn, 
		ItemId, ItemType, LocId, Descr, UnitsBase, Units, LineStatus, GLDesc, AddnlDescr, TaxClass, BinNum, 
		ConversionFactor, LottedYN, InItemYN, ReqShipDate, GLAcct, GLAcctSales, GLAcctWIP,GLAcctAccrual, TransHistID, CustID, 
		ProjID, ProjName, PhaseId, PhaseName, TaskID, TaskName, UnitInc, ExtInc, ProjItemYn, QtySeqNum, SourceType, 
		LineNum, LinkTransId, ReleaseNum, ReqId, LandedCostID, LineSeq,TransHistIDLandedCost,Seq,LinkSeqNum, CF, 
		[Type], ProjectDetailId, ActivityId,ExpReceiptDate)
	SELECT @PostRun, d.TransID, d.EntryNum, d.QtyOrd, d.UnitCost, d.UnitCostFgn, d.ExtCost, d.ExtCostFgn, 
		d.ItemId, d.ItemType, d.LocId, d.Descr, d.UnitsBase, d.Units, d.LineStatus, d.GLDesc, d.AddnlDescr, d.TaxClass, d.BinNum, 
		d.ConversionFactor, d.LottedYN, d.InItemYN, d.ReqShipDate, d.GLAcct, d.GLAcctSales, d.GLAcctWIP,d.GLAcctAccrual, d.TransHistID, p.CustID, 
		p.ProjID, p.ProjName, p.PhaseId, p.PhaseName, p.TaskID, p.TaskName, d.UnitInc, d.ExtInc, d.ProjItemYn, d.QtySeqNum, d.SourceType, 
		d.LineNum, d.LinkTransId, d.ReleaseNum, d.ReqId, d.LandedCostID, d.LineSeq, d.TransHistIDLandedCost,d.Seq,d.LinkSeqNum, d.CF,
		d.[Type], d.ProjectDetailId, d.ActivityId,d.ExpReceiptDate
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransDetail d ON i.TransID = d.TransId 
		LEFT JOIN #TempProject p ON d.TransID = p.TransId AND d.EntryNum = p.EntryNum

	INSERT INTO dbo.tblPoHistDetailLandedCost (PostRun, LCTransSeqNum, TransID, EntryNum, [Description], CostType, Amount, [Level], CalcAmount, LCDtlSeqnum, CF)
	SELECT @PostRun, d.LCTransSeqNum, d.TransID, d.EntryNum, d.[Description], d.CostType, d.Amount, d.[Level], d.CalcAmount , LCDtlSeqnum, d.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransDetailLandedCost d ON i.TransID = d.TransId

	INSERT INTO dbo.tblPoHistInvoiceTot (PostRun, TransId, InvcNum, Status, InvcDate, GLPeriod, FiscalYear, Ten99InvoiceYN, CurrTaxable, CurrNonTaxable, 
		CurrSalesTax, CurrFreight, CurrMisc, CurrDisc, CurrPrepaid, CurrTaxableFgn, CurrNonTaxableFgn, CurrSalesTaxFgn, CurrFreightFgn, CurrMiscFgn, 
		CurrDiscFgn, CurrPrepaidFgn, PostTaxable, PostNonTaxable, PostSalesTax, PostFreight, PostMisc, PostDisc, PostPrepaid, PostTaxableFgn, 
		PostNonTaxableFgn, PostSalesTaxFgn, PostFreightFgn, PostMiscFgn, PostDiscFgn, PostPrepaidFgn, CurrCheckNo, CurrCheckDate, CurrBankID, 
		CurrChkGlPeriod, CurrChkFiscalYear, CurrDueDate1, CurrDueDate2, CurrDueDate3, CurrPmtAmt1, CurrPmtAmt2, CurrPmtAmt3, CurrPmtAmt1Fgn, 
		CurrPmtAmt2Fgn, CurrPmtAmt3Fgn, CurrTaxClassFreight, CurrTaxClassMisc, CurrTaxAdjClass, CurrTaxAdjLocID, CurrTaxAdjAmt, CurrTaxAdjAmtFgn, 
		InvoiceExchRate, PmtCurrencyId, PmtExchRate, GainLoss, DiscDueDate, CF)
	SELECT @PostRun, t.TransId, t.InvcNum, t.Status, t.InvcDate, t.GLPeriod, t.FiscalYear, t.Ten99InvoiceYN, t.CurrTaxable, t.CurrNonTaxable, 
		t.CurrSalesTax, t.CurrFreight, t.CurrMisc, t.CurrDisc, t.CurrPrepaid, t.CurrTaxableFgn, t.CurrNonTaxableFgn, t.CurrSalesTaxFgn, t.CurrFreightFgn, t.CurrMiscFgn, 
		t.CurrDiscFgn, t.CurrPrepaidFgn, t.PostTaxable, t.PostNonTaxable, t.PostSalesTax, t.PostFreight, t.PostMisc, t.PostDisc, t.PostPrepaid, t.PostTaxableFgn, 
		t.PostNonTaxableFgn, t.PostSalesTaxFgn, t.PostFreightFgn, t.PostMiscFgn, t.PostDiscFgn, t.PostPrepaidFgn, t.CurrCheckNo, t.CurrCheckDate, t.CurrBankID, 
		t.CurrChkGlPeriod, t.CurrChkFiscalYear, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3, t.CurrPmtAmt1, t.CurrPmtAmt2, t.CurrPmtAmt3, t.CurrPmtAmt1Fgn, 
		t.CurrPmtAmt2Fgn, t.CurrPmtAmt3Fgn, t.CurrTaxClassFreight, t.CurrTaxClassMisc, t.CurrTaxAdjClass, t.CurrTaxAdjLocID, t.CurrTaxAdjAmt, t.CurrTaxAdjAmtFgn, 
		t.InvoiceExchRate, t.PmtCurrencyId, t.PmtExchRate, t.GainLoss, t.DiscDueDate, t.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransInvoiceTot t ON i.TransID = t.TransId

	INSERT INTO dbo.tblPoHistInvoiceTax (PostRun, TransId, InvcNum, TaxLocID, TaxClass, ExpAcct, CurrTaxAmt, CurrRefundable, CurrTaxable, CurrNonTaxable, 
		RefundAcct, CurrTaxAmtFgn, CurrRefundableFgn, CurrTaxableFgn, CurrNonTaxableFgn, CF)
	SELECT @PostRun, t.TransId, t.InvcNum, t.TaxLocID, t.TaxClass, t.ExpAcct, t.CurrTaxAmt, t.CurrRefundable, t.CurrTaxable, t.CurrNonTaxable, 
		t.RefundAcct, t.CurrTaxAmtFgn, t.CurrRefundableFgn, t.CurrTaxableFgn, t.CurrNonTaxableFgn, t.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransInvoiceTax t ON i.TransID = t.TransId

	INSERT INTO dbo.tblPoHistReceipt (PostRun, TransID, ReceiptNum, ReceiptDate, GlPeriod, FiscalYear, ExchRate, CF)
	SELECT @PostRun, r.TransID, r.ReceiptNum, r.ReceiptDate, r.GlPeriod, r.FiscalYear, r.ExchRate, r.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransReceipt r ON i.TransID = r.TransId

	INSERT INTO dbo.tblPoHistLotRcpt (PostRun, TransId, EntryNum, RcptNum, LotNum, QtyOrder, QtyFilled, UnitCost, UnitCostFgn, ExtCost, ExtCostFgn, HistSeqNum, 
		LotCmnt, [Status], QtySeqNum, ReceiptId, QtyAccRev, AccAdjCostFgn,AccAdjCost,CF, QtySeqNum_Ext, ActivityId)
	SELECT @PostRun, r.TransId, r.EntryNum, r.RcptNum, r.LotNum, r.QtyOrder, r.QtyFilled, r.UnitCost, r.UnitCostFgn, r.ExtCost, r.ExtCostFgn, r.HistSeqNum, 
		r.LotCmnt, r.Status, r.QtySeqNum, r.ReceiptId, r.QtyAccRev, r.AccAdjCostFgn, r.AccAdjCost, r.CF, r.QtySeqNum_Ext, r.ActivityId
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransLotRcpt r ON i.TransID = r.TransId 

	INSERT INTO dbo.tblPoHistReceiptLandedCost (PostRun, ReceiptID, LCTransSeqNum, Amount, PostedAmount, CF )
	SELECT @PostRun, l.ReceiptID, l.LCTransSeqNum, l.Amount, l.PostedAmount, l.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransLotRcpt r ON i.TransID = r.TransId 
		INNER JOIN dbo.tblPoTransReceiptLandedCost l ON r.ReceiptID = l.ReceiptID

	INSERT INTO dbo.tblPoHistInvoice (PostRun, TransID, EntryNum, InvoiceNum, Status, Qty, UnitCost, UnitCostFgn, ExtCost, 
		ExtCostFgn, HistSeqNum, AvgRcptCost, TransHistID, QtySeqNum, InvoiceID, CF) 
	SELECT @PostRun, v.TransID, v.EntryNum, v.InvoiceNum, v.Status, v.Qty, v.UnitCost, v.UnitCostFgn, v.ExtCost, 
		v.ExtCostFgn, v.HistSeqNum, v.AvgRcptCost, v.TransHistID, v.QtySeqNum, v.InvoiceID, v.CF 
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransInvoice v ON i.TransID = v.TransId

	INSERT INTO dbo.tblPoHistInvc_Rcpt (PostRun, InvoiceID, ReceiptID, Qty, QtySeqNum, HistSeqNum, CF)
	SELECT @PostRun, ir.InvoiceID, ir.ReceiptID, ir.Qty, ir.QtySeqNum, ir.HistSeqNum, ir.CF
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransInvoice v ON i.TransID = v.TransId 
		INNER JOIN dbo.tblPoTransInvc_Rcpt ir ON v.InvoiceID = ir.InvoiceID 

	INSERT INTO dbo.tblPoHistSer (PostRun, TransId, EntryNum, RcptNum, LotNum, SerNum, InvcNum, SerCmnt, RcptUnitCost, RcptUnitCostFgn, RcptStatus, InvcUnitCost, 
		InvcUnitCostFgn, InvcStatus, SerHistSeqNum, ExchRateSRec, ExchRateSInv, CF, ExtLocAId, ExtLocBId)
	SELECT @PostRun, s.TransId, s.EntryNum, s.RcptNum, s.LotNum, s.SerNum, s.InvcNum, s.SerCmnt, s.RcptUnitCost, s.RcptUnitCostFgn, s.RcptStatus, s.InvcUnitCost, 
		s.InvcUnitCostFgn, s.InvcStatus, s.SerHistSeqNum, s.ExchRateSRec, s.ExchRateSInv, s.CF, a.ExtLocID, b.ExtLocID
	FROM #CompletedTransactions i INNER JOIN dbo.tblPoTransSer s ON i.TransID = s.TransId 
	LEFT JOIN dbo.tblWmExtLoc a ON s.ExtLocA = a.Id
	LEFT JOIN dbo.tblWmExtLoc b ON s.ExtLocB = b.Id

	INSERT INTO dbo.tblPoHistDeposit (ID ,TransPostRun,TransID, DepositDate, Amount,AmountBase,AmountApplied,AmountAppliedBase,FiscalYear,FiscalPeriod,EntryDate
      ,InvoiceCounter,Notes,BankID,PaymentNumber,PostRun,DepositGLAcct,CF,ExchRate)
	SELECT   ID ,@PostRun, d.TransID, DepositDate, Amount,AmountBase,AmountApplied,AmountAppliedBase,FiscalYear,FiscalPeriod,EntryDate
      ,InvoiceCounter,Notes,BankID,PaymentNumber,PostRun,DepositGLAcct,CF, d.ExchRate
	FROM #CompletedTransactions i 
	INNER JOIN dbo.tblPoTransDeposit d ON d.TransID =i.TransID

	INSERT INTO dbo.tblPoHistDeposit (ID ,TransPostRun,TransID, DepositDate, Amount,AmountBase,AmountApplied,AmountAppliedBase,FiscalYear,FiscalPeriod,EntryDate
      ,InvoiceCounter,Notes,BankID,PaymentNumber,PostRun,DepositGLAcct,CF,ExchRate)
	SELECT   ID ,@PostRun, d.TransID, DepositDate, Amount,AmountBase,AmountApplied,AmountAppliedBase,FiscalYear,FiscalPeriod,EntryDate
      ,InvoiceCounter,d.Notes,BankID,PaymentNumber,PostRun,DepositGLAcct,d.CF,d.ExchRate
	FROM dbo.tblPoTransDeposit d
	LEFT JOIN dbo.tblPoTransHeader h  ON d.TransID =h.TransID
	WHERE h.TransId IS NULL
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OrderHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_OrderHistory_proc';



CREATE PROCEDURE dbo.trav_PoTransPost_DoAccrualPosted_proc
AS
SET NOCOUNT ON
BEGIN TRY
/*    'if accrual flag is set in the options, read thru tblPoTransReceipts
    'for posted receipts (status=1) and AccAdjCost<>0 and make accrual entries
    'debit account accrual account from line item
    'credit account AP accrual account from distribution code
*/
	DECLARE @PostRun nvarchar(14), @WksDate datetime,@CurrBase pCurrency,@PoInYn bit,
            @LinkID nvarchar(15), @LinkIDSub nvarchar(15), @LinkIDSubLine Int         
       
      SELECT @LinkID = 'ACCRUAL', @LinkIDSub = NULL , @LinkIDSubLine = -3

      --Retrieve global values
      --Modified for PO Extending PO Accrual Functionality 
      
      SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
      SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
      SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
      SELECT @PoInYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoInYn'

      IF @PostRun IS NULL OR @WksDate IS NULL OR @CurrBase IS NULL OR @PoInYn IS NULL
      BEGIN
            RAISERROR(90025,16,1)
      END

      --IN Accrual
      IF (@PoInYn = 1)
      BEGIN
		  INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
		  Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
		  LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
		  SELECT @PostRun, NULL, NULL,  t.GlPeriod, 99998, 105, 
		   Sum(Sign(TransType) * r.AccAdjCost),  Sum(Sign(TransType) * r.AccAdjCost), 
		   min(t.ReceiptDate), @WksDate,  'IN Accrual', 'GOODS RCVD', d.GLAcctAccrual,
		   CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine, @CurrBase, 1,
		  CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
		  FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
		  INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
		  --Modiifed for PO Accural Enhancement
		  INNER JOIN dbo.tblInItem i on d.ItemId=i.ItemId
		  INNER JOIN dbo.tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
		  INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
		  WHERE r.Status = 1 AND (ISNULL(d.LinkSeqNum,0) = 0 OR h.DropShipYn = 0)  AND ISNULL(d.ProjectDetailId,0) = 0
		  GROUP BY t.FiscalYear, t.GlPeriod, d.GLAcctAccrual
		  HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 
		  
		  --AP Accrual
		  INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
		  GlPeriod, EntryNum, Grouping, 
		  Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
		  LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
		  SELECT @PostRun, NULL, NULL, 
		   t.GlPeriod, 99998, 107, 
		   - Sum(Sign(TransType) * r.AccAdjCost), 
		   - Sum(Sign(TransType) * r.AccAdjCost), 
		   min(t.ReceiptDate), @WksDate, 
		   'AP Accrual', 'GOODS RCVD', c.AccrualGLAcct, 
		   CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine,
			@CurrBase, 1,
		  CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
		   CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
		  FROM tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
		  INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID 
		  --Modified for PO Accural Enhancement
		  INNER JOIN dbo.tblInItem i on d.ItemId=i.ItemId
		  INNER JOIN tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
		  INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum 
		  INNER JOIN dbo.tblApDistCode c on h.DistCode = c.DistCode 
		  WHERE r.Status = 1 AND (ISNULL(d.LinkSeqNum,0) = 0 OR h.DropShipYn = 0)  AND ISNULL(d.ProjectDetailId,0) = 0
		  GROUP BY t.FiscalYear, t.GlPeriod, c.AccrualGLAcct
		  HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

	
	  
	  END
 
      --Exp Accrual
      INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, 
       t.GlPeriod, 99998, 106, 
       Sum(Sign(TransType) * r.AccAdjCost), 
       Sum(Sign(TransType) * r.AccAdjCost), 
       min(t.ReceiptDate), @WksDate, 
       'Exp Accrual', 'GOODS RCVD', d.GLAcctAccrual,
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine,
        @CurrBase, 1,
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM ((tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransID = b.TransID) 
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID)
      --Modified for PO Accural Enhancement
      LEFT JOIN dbo.tblInItem i on d.ItemId=i.ItemId 
      INNER JOIN tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum 
      WHERE r.Status = 1 AND (@PoInYn = 0 OR i.ItemId IS NULL) AND (ISNULL(d.LinkSeqNum,0) = 0 OR h.DropShipYn = 0)  AND ISNULL(d.ProjectDetailId,0) = 0
      GROUP BY t.FiscalYear, t.GlPeriod, d.GLAcctAccrual
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

	

      --AP Accrual
      INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, 
       t.GlPeriod, 99998, 107, 
       - Sum(Sign(TransType) * r.AccAdjCost), 
       - Sum(Sign(TransType) * r.AccAdjCost), 
       min(t.ReceiptDate), @WksDate, 
       'AP Accrual', 'GOODS RCVD',c.AccrualGLAcct,--Modified the field for PO Extending PO Accrual Functionality ) 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine,
        @CurrBase, 1,
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID 
      --Modified for PO Extending Accrual Functionality 
      LEFT JOIN dbo.tblInItem i on d.ItemId=i.ItemId
      INNER JOIN tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum  
      INNER JOIN dbo.tblApDistCode c on h.DistCode = c.DistCode 
      WHERE r.Status = 1 AND (@PoInYn = 0 OR i.ItemId IS NULL) AND (ISNULL(d.LinkSeqNum,0) = 0 OR h.DropShipYn = 0)  AND ISNULL(d.ProjectDetailId,0) = 0 
      GROUP BY t.FiscalYear, t.GlPeriod,c.AccrualGLAcct
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

	    --Drop Ship
	  INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, t.GlPeriod, 99998, 105, 
      Sum(Sign(TransType) * r.AccAdjCost), Sum(Sign(TransType) * r.AccAdjCost), 
      min(t.ReceiptDate), @WksDate, 'Drop ship', 'GOODS RCVD', d.GLAcct,
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine, @CurrBase, 1,
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM ((tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransID = b.TransID) 
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID)
      INNER JOIN tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum 
      WHERE r.Status = 1 AND  (ISNULL(d.LinkSeqNum,0) > 0 AND h.DropShipYn = 1)  AND ISNULL(d.ProjectDetailId,0) = 0
      GROUP BY t.FiscalYear, t.GlPeriod, d.GLAcct
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

	  INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, t.GlPeriod, 99998, 107, 
      - Sum(Sign(TransType) * r.AccAdjCost),  - Sum(Sign(TransType) * r.AccAdjCost), 
      min(t.ReceiptDate), @WksDate, 'AP Accrual', 'GOODS RCVD',c.AccrualGLAcct,
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine, @CurrBase, 1,
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID 
      INNER JOIN tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum  
      INNER JOIN dbo.tblApDistCode c on h.DistCode = c.DistCode 
      WHERE r.Status = 1 AND (ISNULL(d.LinkSeqNum,0) > 0 AND h.DropShipYn = 1)  AND ISNULL(d.ProjectDetailId,0) = 0 
      GROUP BY t.FiscalYear, t.GlPeriod,c.AccrualGLAcct
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 
	 

      --Project/Job Accrual
      INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, 
       t.GlPeriod, 99998, 106, 
       Sum(Sign(TransType) * r.AccAdjCost), 
       Sum(Sign(TransType) * r.AccAdjCost), 
       min(t.ReceiptDate), @WksDate, 
       'Project/Job Accrual', 'GOODS RCVD',d.GLAcctAccrual, 
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine,
        @CurrBase, 1,
      CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN -Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID
      INNER JOIN dbo.tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum
      WHERE r.Status = 1 AND ISNULL(d.ProjectDetailId,0) <> 0
      GROUP BY t.FiscalYear, t.GlPeriod, d.GLAcctAccrual
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

      --AP Accrual
      INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, 
      GlPeriod, EntryNum, Grouping, 
      Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
      LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
      SELECT @PostRun, NULL, NULL, 
       t.GlPeriod, 99998, 107, 
       - Sum(Sign(TransType) * r.AccAdjCost), 
       - Sum(Sign(TransType) * r.AccAdjCost), 
       min(t.ReceiptDate), @WksDate, 
       'AP Accrual', 'GOODS RCVD', c.AccrualGLAcct, 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       t.FiscalYear, @LinkID, @LinkIDSub, @LinkIDSubLine,
        @CurrBase, 1,
      CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) > 0 THEN - Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END, 
       CASE WHEN - Sum(Sign(TransType) * r.AccAdjCost) < 0 THEN Sum(Sign(TransType) * r.AccAdjCost) ELSE 0 END
      FROM tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
      INNER JOIN tblPoTransDetail d ON h.TransId = d.TransID 
      INNER JOIN dbo.tblPoTransLotRcpt r ON d.EntryNum = r.EntryNum AND d.TransID = r.TransID 
      INNER JOIN dbo.tblPoTransReceipt t ON r.TransId = t.TransId AND r.RcptNum = t.ReceiptNum 
      INNER JOIN dbo.tblApDistCode c on h.DistCode = c.DistCode 
      WHERE r.Status = 1 AND ISNULL(d.ProjectDetailId,0) <> 0
      GROUP BY t.FiscalYear, t.GlPeriod, c.AccrualGLAcct
      HAVING Sum(Sign(TransType) * r.AccAdjCost) <> 0 

      UPDATE dbo.tblPoTransLotRcpt SET AccAdjCost = 0, AccAdjCostFgn = 0
      FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList b ON h.TransId = b.TransId 
      INNER JOIN dbo.tblPoTransDetail  d ON h.TransId = d.TransID 
      INNER JOIN dbo.tblPoTransLotRcpt  ON d.EntryNum = dbo.tblPoTransLotRcpt.EntryNum AND d.TransID = dbo.tblPoTransLotRcpt.TransID 
      WHERE dbo.tblPoTransLotRcpt.Status = 1 AND dbo.tblPoTransLotRcpt.AccAdjCost <> 0 AND dbo.tblPoTransLotRcpt.AccAdjCostFgn <> 0 
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DoAccrualPosted_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_DoAccrualPosted_proc';


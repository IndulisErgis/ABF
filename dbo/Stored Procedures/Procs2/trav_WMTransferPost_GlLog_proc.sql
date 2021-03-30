
CREATE PROCEDURE [dbo].[trav_WMTransferPost_GlLog_proc]
AS
BEGIN TRY  
 DECLARE @gInPostDtlGlYn bit,@WrkStnDate datetime, @PostRun pPostRun,  
  @CurrBase pCurrency,@CompId nvarchar(3),@FiscalPeriod smallint,@FiscalYear smallint,@ApplyXferCostAdj tinyint,
  @PrecUnitCost  tinyint,@PrecCurr tinyint
 
 SELECT @FiscalYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
 SELECT @FiscalPeriod = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'   
 SELECT @gInPostDtlGlYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PostDtlGlYn'  
 SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'  
 SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'  
 SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'  
 SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId' 
 SELECT @ApplyXferCostAdj = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'ApplyXferCostAdj'  
 SELECT @PrecUnitCost = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecUnitCost'   
 SELECT @PrecCurr = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'    
 
 IF @FiscalYear IS NULL OR @FiscalPeriod IS NULL OR @gInPostDtlGlYn  IS NULL OR 
    @WrkStnDate  IS NULL OR @PostRun IS NULL OR @CurrBase IS NULL OR @CompId  IS NULL OR
     @ApplyXferCostAdj IS NULL OR @PrecUnitCost IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END 

--Temp table #WMTranferPost(Created from BL)- Used to load pick and receipt and apply filter condition 	
--Create Table #WMTranferPost(TranKey int,TranPickKey int,/*0=Pick/1=Receipt*/TransType tinyint,TransDate datetime,ItemId pItemId,LocId pLocId,BaseQty pDecimal,ExtCost pDecimal,GlPeriod smallint,FiscalYear smallint,AdjLocId pLocId,[Status] tinyint,QtyBase pDecimal)

--Temp table #WMTransferPostLog(Created from BL)- Used to load GL logs.
--CREATE TABLE #WMTransferPostLog ( 
--  [ItemID] [dbo].[pItemID] NULL,  
--  [LocID] [dbo].[pLocID] NULL,  
--  [FiscalPeriod] [smallint] NULL,  
--  [TransDate] [datetime] NULL,  
--  [Description] [nvarchar](30) NULL,  
--  [GlAccount] [dbo].[pGlAcct] NULL,  
--  [DebitAmt] [dbo].[pDecimal] NULL,  
--  [CreditAmt] [dbo].[pDecimal] NULL,  
--  [FiscalYear] [smallint] NULL,  
--  [TransId] int NULL,  
--  [TransType] smallint 
--  )  


 --create log records for picks and receipts (Debit/Credit Inventory Account)
INSERT INTO #WMTransferPostLog (ItemID, LocID, FiscalPeriod, TransDate,   
   [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)    
   	Select t.ItemId, t.LocId,t.GlPeriod,t.TransDate ,t.LocId, g.GlAcctInv,		
		 Case When t.TransType = 1 Then t.ExtCost Else 0 End,--Debit Acct for Receipts (To values)
		 Case When t.TransType = 0 Then t.ExtCost Else 0 End,--Credit Acct for Picks (From values)
		 t.FiscalYear,t.TranKey,t.TransType
	From #WMTranferPost t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and t.LocId = l.LocId
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode
	Where t.[Status] = 0 -- Unposted 
	    AND t.ExtCost <> 0 
	
--offset each Inventory Account transaction to the In Transit Account
--	this is to ensure that each glperiod/year balances when the picks and receipts span gl periods
INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
    [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId, t.LocId,
		 t.GlPeriod, t.TransDate, 
		 t.LocId, g.GLAcctInTransit,
	     Case When t.TransType = 1 Then 0 Else t.ExtCost End, --Credit Acct for Receipts (To values)
		 Case When t.TransType = 0 Then 0 Else t.ExtCost End, --Debit Acct for Picks (From values)
		 t.FiscalYear,t.TranKey,t.TransType
	From #WMTranferPost t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and t.AdjLocId = l.LocId --GL Acct via Bus rule - Apply Transfer Cost/Adjustment
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode
	Where t.[Status] = 0 -- Unposted
	   AND t.ExtCost <> 0
	   

---create log record for transfer cost 
--- Create a temp table to apply Bus rule Apply Transfer Cost/Adjustment
-- GL log entries for transfer cost should be generated only if transfer is completed.
	Select * into #WmTransfer From 
	 (
	 	   Select TranKey,ItemId,CostTransfer,
	 	   Case When @ApplyXferCostAdj = 0 Then t.LocId Else t.LocIdTo End as AdjLocId -- Use Bus rule - Apply Transfer Cost/Adjustment
	       from dbo.tblWmTransfer t where t.CostTransfer <> 0 and t.[Status] = 2 -- Completed
	       AND t.TranKey IN 
	       (
	           Select TranKey From #WMTranferPost Group By TranKey
		   )
	 ) t	 	 
	 
--create log record for transfer cost 
--	credit the GlAcctXferCost account 
INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
   [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId,t.AdjLocId,
	      @FiscalPeriod, @WrkStnDate,
	       t.AdjLocId, g.GLAcctXferCost,		   
	      Case When t.CostTransfer < 0 Then abs(t.CostTransfer) Else 0 End, --debit
		  Case When t.CostTransfer > 0 Then t.CostTransfer Else 0 End, --credit
		  @FiscalYear,t.TranKey,2
	From #WmTransfer t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and l.LocId  = t.AdjLocId
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode
	
		
--create log record for transfer cost 
--debit the GLAcctInTransit account 
INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
   [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId,t.AdjLocId,
	     @FiscalPeriod, @WrkStnDate,		 
		  t.AdjLocId,g.GLAcctInTransit,		 
		 Case When t.CostTransfer > 0 Then t.CostTransfer Else 0 End, --debit
		 Case When t.CostTransfer < 0 Then abs(t.CostTransfer) Else 0 End, --credit
		 @FiscalYear,t.TranKey,2
	From #WmTransfer t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and  l.LocId  = t.AdjLocId
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode

--When transfer is completed and there is posted received quantity, GL entries should be generated for each posted received quantity. 
--- Create a temp table to calculate RcvdTransferCost
     Select * into #PostedReceipts From 
	 (
		 Select p.*, ROUND(ROUND(t.CostTransfer/s.TotalRcvd,@PrecUnitCost) * p.QtyBase,@PrecCurr) as RcvdTransferCost
	     From #WMTranferPost p 
		 inner join #WmTransfer t on p.TranKey =    t.TranKey  
	                                       AND p.TransType = 1  -- Receipt
	                                       AND p.[Status] = 1   -- Posted
		 inner join  (
						  Select TranKey,SUM(QtyBase) as TotalRcvd from  #WMTranferPost
						  where  TransType = 1 -- Receipt
						  group by TranKey
					   ) s on s.TranKey = p.TranKey
	 )r
	
   --Debit inventory account(to location) when calculated amount is greater than zero.
  -- Credit inventory account(to location) when calculated amount is less than zero.
   INSERT INTO #WMTransferPostLog (ItemID, LocID, FiscalPeriod, TransDate,   
   [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)    
   	Select t.ItemId, t.LocId,@FiscalPeriod,@WrkStnDate ,t.LocId, g.GlAcctInv,		
		 Case When t.RcvdTransferCost > 0 Then t.RcvdTransferCost Else 0 End,--Debit 
		 Case When t.RcvdTransferCost < 0 Then abs(t.RcvdTransferCost) Else 0 End,--Credit 
		 @FiscalYear,t.TranKey,1
	From #PostedReceipts t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and t.LocId = l.LocId
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode

	
	--Debit in-transit account(Use Bus rule - Apply Transfer Cost/Adjustment) when calculated amount is less than zero.
    --Credit in-transit account(Use Bus rule -  Apply Transfer Cost/Adjustment) when calculated amount is greater than zero.
    INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
    [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId, t.LocId,
		 @FiscalPeriod,@WrkStnDate, 
		 t.LocId, g.GLAcctInTransit,	     
		 Case When t.RcvdTransferCost < 0 Then abs(t.RcvdTransferCost) Else 0 End,--Debit 
		 Case When t.RcvdTransferCost > 0 Then  t.RcvdTransferCost Else 0 End,--Credit 
		 @FiscalYear,t.TranKey,1
	From #PostedReceipts t 
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and t.AdjLocId = l.LocId --GL Acct via Bus rule - Apply Transfer Cost/Adjustment
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode

	
		
--Post variances between the picks + transfer cost vs receipts to the Adjustment Account
--Credit the In Transit Account for the In Transit Location
INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
   [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId, p.AdjLocId, @FiscalPeriod, @WrkStnDate,
		 p.AdjLocId,g.GLAcctInTransit,		
		 Case When (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) > 0 Then (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) Else 0 End, --Debit
		 Case When (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) < 0 Then abs(IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) Else 0 End, --Credit 
		 @FiscalYear,t.TranKey,3
	From dbo.tblWmTransfer t
	Inner Join (Select TranKey, AdjLocId, Sum(ExtCost) ExtCost 
		From #WMTranferPost Where TransType = 0 --Picks(From)
		Group By TranKey, AdjLocId) p
	on t.TranKey = p.TranKey
	Left Join (Select TranKey, Sum(ExtCost) ExtCost
		From #WMTranferPost Where TransType = 1 --Receipts(To)
		Group By TranKey) r
	on t.TranKey = r.TranKey
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and p.AdjLocId = l.LocId --GL Acct via In Transit Loc Id
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode
	Where t.[Status] = 2 -- Completed Transfer
	   AND (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) <> 0
	
	
--Debit the Adjustment Account via the option controlled location
INSERT INTO #WMTransferPostLog(ItemID, LocID, FiscalPeriod, TransDate,   
    [Description], GlAccount, DebitAmt, CreditAmt, FiscalYear, TransId, TransType)
	Select t.ItemId, p.AdjLocId, @FiscalPeriod, @WrkStnDate,
		  p.AdjLocId,g.GLAcctInvAdj ,
		  Case When (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) < 0 Then abs(IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) Else 0 End, --debit
		  Case When (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) > 0 Then (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) Else 0 End, --credit		  
		  @FiscalYear,t.TranKey,3
	From dbo.tblWmTransfer t
	Inner Join (Select TranKey, AdjLocId, Sum(ExtCost) ExtCost 
		From #WMTranferPost Where TransType = 0 --Picks(From)
		Group By TranKey, AdjLocId) p
	on t.TranKey = p.TranKey
	Left Join (Select TranKey, Sum(ExtCost) ExtCost
		From #WMTranferPost Where TransType = 1 --Receipts(To)
		Group By TranKey) r
	on t.TranKey = r.TranKey
	Left Join dbo.tblInItemLoc l On t.ItemId = l.ItemId and p.AdjLocId = l.LocId 
	Left Join dbo.tblInGlAcct g on l.GlAcctCode = g.GlAcctCode
	Where t.[Status] = 2 -- Completed Transfer
	   AND (IsNull(r.ExtCost,0) - (p.ExtCost + t.CostTransfer)) <> 0
	
-- Build Summary Log 
 IF @gInPostDtlGlYn = 0  
 BEGIN  
  INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,  
	CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID)  
	SELECT  @PostRun,FiscalYear, FiscalPeriod, GlAccount, SUM(DebitAmt), 'WM','Sum Trans Entry From WM', SUM(DebitAmt), 0,  
	SUM(DebitAmt), 0,'WM',@WrkStnDate,MIN(TransDate),@CurrBase,1,@CompId  
	FROM #WMTransferPostLog  
	GROUP BY [FiscalYear], FiscalPeriod, GlAccount HAVING SUM(DebitAmt) <> 0  
  
  INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,  
	 CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID)  
	 SELECT  @PostRun,FiscalYear, FiscalPeriod, GlAccount, SUM(CreditAmt),'WM', 'Sum Trans Entry From WM', 0, SUM(CreditAmt),  
	 0, SUM(CreditAmt),'WM',@WrkStnDate,MIN(TransDate),@CurrBase,1,@CompId  
     FROM #WMTransferPostLog  
	 GROUP BY [FiscalYear], FiscalPeriod, GlAccount HAVING SUM(CreditAmt) <> 0  
 END  
 ELSE  
 BEGIN  
  INSERT #GlPostLogs(PostRun,FiscalYear,FiscalPeriod,GlAccount,AmountFgn,Reference,[Description],DebitAmount,  
	  CreditAmount,DebitAmountFgn,CreditAmountFgn,SourceCode,PostDate,TransDate,CurrencyId,ExchRate,CompID,ItemId,LocId,LinkID,LinkIDSubLine)  
	  SELECT @PostRun,FiscalYear, FiscalPeriod, GlAccount,ABS(DebitAmt-CreditAmt),'WM',[Description],DebitAmt,  
	  CreditAmt,DebitAmt,CreditAmt,'WM',@WrkStnDate,TransDate,@CurrBase,1,@CompId,ItemId,LocId,TransId,TransType  
	  FROM  #WMTransferPostLog  
 END 
	
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_GlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_WMTransferPost_GlLog_proc';


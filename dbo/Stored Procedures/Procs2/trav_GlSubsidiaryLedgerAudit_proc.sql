
CREATE PROCEDURE dbo.trav_GlSubsidiaryLedgerAudit_proc
@FiscalPeriod smallint,
@FiscalYear smallint,
@AppFlags int = 15, --bitmasked flags (1=AP/2=AR/4=IN/8=FA)
@GlAcctCustomerDeposit pGlAcct,
@BaseCurrency pCurrency ='USD',
@CurrencyPrecision tinyint = 2, 
@CostingMethod tinyint = 0 --0;FIFO;1;LIFO;2;Average;3;Standard - 2;Average is not supported
AS
BEGIN TRY
	Set Nocount on

	DECLARE @BrBalance decimal

	Create Table #Audit
	(	
		SourceType tinyint, --see enum
		AppId nvarchar(2),
		PostRun pPostRun NULL,
		LinkId nvarchar(255),
		LinkIdSub nvarchar(15),
		LinkIDSubLine int,
		AccountId pGlAcct, 
		TransDate datetime,
		Amount pCurrDecimal Default(0), 
	)

	--SourceType enum
	--	0 = GL
	--	9 = GL Beginning Balance
	--	10 = AP Invoice
	--	11 = AP Check
	--	19 = AP Beginning Balance
	--	20 = AR Invoice
	--	21 = AR Payment
	--	22 = AR Finance Charge
	--	29 = AR Beginning Balance
	--	30 = IN History
	--	39 = IN Beginning Balance
	--	40 = FA
	--	49 = FA Beginning Balance

	--	51 = BR Disbursement
	--	52 = BR Deposit
	--	53 = BR Transfer
	--  54 = BR Adjustment

	Create Table #AppList
	(
		AppId nvarchar(2)
	)


	Create Table #AppAccts
	(
		AppId nvarchar(2),
		GlAcct pGlAcct,
		DfltBalType Smallint Default(1) --default to Debit
	)
	Create Index IX_AppIdGlAcct on #AppAccts(AppId, GlAcct)

	Create Table #InValue
	(
		ItemId pItemId,
		LocId pLocId,
		ExtCost pCurrDecimal
	)
	Create Index IX_InValue on #InValue(ItemId, LocId)


	DECLARE @BeginningBalance bit
	DECLARE @YrPdToProcess int

	SET @BeginningBalance = 1 --option flag for including beginning balances
	SELECT @YrPdToProcess = (@FiscalYear * 1000) + @FiscalPeriod

	------------------------------------------------------
	------------------------- AP -------------------------
	------------------------------------------------------
	If (@AppFlags & 1) = 1
	Begin
		--add AP to the application list
		INSERT INTO #AppList (AppId) VALUES ('AP')
	
		--capture invoice/debit memo details
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 10, 'AP', h.PostRun, h.TransId, h.InvoiceNum, 0
			, ISNULL(h.GLAcctAP, d.PayablesGLAcct), h.InvoiceDate, SIGN(TransType) * (Subtotal + SalesTax + TaxAdjAmt + Freight + Misc)
		FROM dbo.tblApHistHeader h (NOLOCK)
		LEFT JOIN dbo.tblApDistCode d (NOLOCK) ON h.DistCode = d.DistCode
		WHERE h.FiscalYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod

		--capture payment/check information (back out all payments as of the payment date)
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 11, 'AP', h.PostRun, NULL, NULL, NULL
			, ISNULL(h.GLAcctAP, d.PayablesGLAcct), h.CheckDate, -h.BaseGrossAmtDue
		FROM dbo.tblApCheckHist h
		LEFT JOIN dbo.tblApDistCode d (NOLOCK) ON h.DistCode = d.DistCode
		WHERE h.FiscalYear = @FiscalYear AND h.GlPeriod = @FiscalPeriod

		--capture voided payment information (reapply voids as of the voided date)
		--	use the period conversion via the void date for the most accurate period/year filtering
		--  (Missing period conversion table entries will prevent the capture of void information)
		--Note: voided period/year is not available in check history - could cause variance between AP History and GL
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 11, 'AP', NULL, NULL, NULL, NULL --no valid links between check history and GL for voids
			, ISNULL(h.GLAcctAP, d.PayablesGLAcct), h.VoidDate, h.BaseGrossAmtDue
		FROM dbo.tblApCheckHist h
		LEFT JOIN dbo.tblApDistCode d (NOLOCK) ON h.DistCode = d.DistCode
		CROSS JOIN dbo.tblSmPeriodConversion p 
		WHERE h.VoidDate BETWEEN p.BegDate AND p.EndDate
			AND h.VoidYn = 1 --voids only
			AND p.GlYear = @FiscalYear AND p.GlPeriod = @FiscalPeriod
			
		IF @BeginningBalance = 1
		BEGIN
			--Capture all open invoice transactions prior to the given period/year
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
				, AccountId, TransDate, Amount)
			SELECT 19, 'AP', NULL, NULL, NULL, NULL
				, d.PayablesGLAcct, NULL, SUM(i.BaseGrossAmtDue)
			FROM dbo.tblApOpenInvoice i (NOLOCK) 
			INNER JOIN dbo.tblApDistCode d (NOLOCK) ON i.DistCode = d.DistCode
			WHERE (i.FiscalYear * 1000) + i.GlPeriod < @YrPdToProcess --must consider status 3 (prepaid) as open until checks are prepared
			GROUP BY d.PayablesGlAcct
		
			--Add (Back out) Checks
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
				, AccountId, TransDate, Amount)
			SELECT 19, 'AP', NULL, NULL, NULL, NULL
				, d.PayablesGLAcct, NULL, SUM(-i.BaseGrossAmtDue)
			FROM dbo.tblApOpenInvoice i (NOLOCK) 
			INNER JOIN dbo.tblApDistCode d (NOLOCK) ON i.DistCode = d.DistCode
			WHERE i.[Status] = 4 AND (i.CheckYear * 1000) + i.CheckPeriod < @YrPdToProcess
			GROUP BY d.PayablesGlAcct
		END
	END

	------------------------------------------------------
	------------------------- AR -------------------------
	------------------------------------------------------
	If (@AppFlags & 2) = 2
	Begin
		--add AR to the application list
		INSERT INTO #AppList (AppId) VALUES ('AR')

		--capture invoice/credit memo details
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 20, 'AR', h.PostRun, h.TransId, h.InvcNum, 0
			, ISNULL(h.GLAcctReceivables, d.GLAcctReceivables), h.InvcDate, SIGN(h.[TransType]) * (h.TaxSubtotal + h.NonTaxSubtotal + h.SalesTax + h.Freight + h.Misc + h.CalcGainLoss)
		FROM dbo.tblArHistHeader h (NOLOCK)
		LEFT JOIN dbo.tblArDistCode d (NOLOCK) ON h.DistCode = d.DistCode
		WHERE h.FiscalYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod
			AND h.[VoidYn] = 0 AND NULLIF(RTRIM([CustId]), '') is not null

		--capture payment details
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 21, 'AR', p.PostRun, p.TransId, p.InvcNum, -1 
			, ISNULL(p.GLRecvAcct, d.GLAcctReceivables), p.PmtDate, -(p.PmtAmt + p.DiffDisc - p.CalcGainLoss)
		FROM dbo.tblArHistPmt p (NOLOCK)
		LEFT JOIN dbo.tblArDistCode d (NOLOCK) ON p.DistCode = d.DistCode
		WHERE p.FiscalYear = @FiscalYear AND p.GLPeriod = @FiscalPeriod
			AND p.[VoidYn] = 0
			AND NULLIF(RTRIM([CustId]), '') is not null

		--capture finance charge details
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 22, 'AR', f.PostRun, 'FINCH', NULL, -5
			, ISNULL(f.GlAcctReceivables, d.GLAcctReceivables), f.FinchDate, f.FinchAmt
		FROM dbo.tblArHistFinch f (NOLOCK)
		LEFT JOIN dbo.tblArCust c (NOLOCK) ON f.CustID = c.CustId
		LEFT JOIN dbo.tblArDistCode d (NOLOCK) ON c.DistCode = d.DistCode
		WHERE f.FiscalYear = @FiscalYear AND f.GLPeriod = @FiscalPeriod
		
		
		IF @BeginningBalance = 1
		BEGIN
			--Capture all open invoice transactions prior to the given period/year
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
				, AccountId, TransDate, Amount)
			SELECT 29, 'AR', NULL, NULL, NULL, NULL
				, d.GLAcctReceivables, NULL
				, Sum(CASE WHEN [RecType] > 0 THEN Amt ELSE -Amt END)
			FROM dbo.tblArOpenInvoice o 
			INNER JOIN dbo.tblArDistCode d ON o.DistCode = d.DistCode AND o.RecType<>5
			WHERE (o.Fiscalyear * 1000) + o.GlPeriod < @YrPdToProcess
			Group By d.GlAcctReceivables
		END
	END

	------------------------------------------------------
	------------------------- IN -------------------------
	------------------------------------------------------
	If (@AppFlags & 4) = 4
	Begin
		--add IN to the application list
		INSERT INTO #AppList (AppId) VALUES ('IN')
		
		--capture normal inventory transactions
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 30, 'IN', NULL
			, CASE WHEN h.[Source] IN (18, 76) THEN h.RefId ELSE h.TransId END --remap value of LinkID for MP
			, NULL, NULL 
			, a.GLAcctInv, h.TransDate
			, CASE WHEN h.[Source] < 70 THEN h.CostExt ELSE -h.CostExt END
		FROM dbo.tblInHistDetail h (NOLOCK)
		LEFT JOIN dbo.tblInItemLoc l (NOLOCK) ON h.ItemId = l.ItemId AND h.LocId = l.LocId
		LEFT JOIN dbo.tblInGlAcct a (NOLOCK) ON l.GlAcctCode = a.GlAcctCode
		WHERE h.SumYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod AND h.DropShipYn=0
			AND h.[Source] > 0 AND h.[Source] NOT IN (200, 201) AND (h.Qty > 0 OR (h.AppId = 'PO' AND h.Qty = 0 AND h.CostExt <> 0 )) -- Po invoice coversion
		
		--back out receipts for invoiced transactions
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 30, 'IN', NULL
			, CASE WHEN h.[Source] IN (18, 76) THEN h.RefId ELSE h.TransId END --remap value of LinkID for MP
			, NULL, NULL 
			, a.GLAcctInv, h.TransDate
			, CASE WHEN h.[Source] < 70 THEN -(h.Qty * r.CostUnit) ELSE (h.Qty * r.CostUnit) END
		FROM dbo.tblInHistDetail h (NOLOCK)
		INNER JOIN dbo.tblInHistDetail r ON h.HistSeqNum_Rcpt = r.HistSeqNum
		LEFT JOIN dbo.tblInItemLoc l (NOLOCK) ON h.ItemId = l.ItemId AND h.LocId = l.LocId
		LEFT JOIN dbo.tblInGlAcct a (NOLOCK) ON l.GlAcctCode = a.GlAcctCode
		WHERE h.SumYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod
			AND h.Qty > 0 AND h.DropShipYn=0

		--capture cogs/ppv entries
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 30, 'IN', NULL
			, CASE WHEN h.[AppId] = 'MP' THEN h.RefId ELSE h.TransId END --remap value of LinkID for MP
			, NULL, NULL 
			, a.GLAcctInv, h.TransDate, -h.CostExt
		FROM dbo.tblInHistDetail h (NOLOCK)
		LEFT JOIN dbo.tblInItemLoc l (NOLOCK) ON h.ItemId = l.ItemId AND h.LocId = l.LocId
		LEFT JOIN dbo.tblInGlAcct a (NOLOCK) ON l.GlAcctCode = a.GlAcctCode
		WHERE h.SumYear = @FiscalYear AND h.GLPeriod = @FiscalPeriod AND h.DropShipYn=0
			AND h.[Source] IN (200, 201)

		IF @BeginningBalance = 1
		BEGIN
			--capture current serialized value
			INSERT INTO #InValue(ItemId, LocId, ExtCost)
			SELECT s.ItemId, s.LocId
				, SUM(CASE WHEN @CostingMethod = 3 AND i.CostMethodOverride = 2 THEN ROUND(s.QtyOnHand * l.CostStd, @CurrencyPrecision) ELSE s.Cost END)
			FROM dbo.trav_InItemOnHandSer_view s 
			INNER JOIN dbo.tblInItemLoc l ON s.ItemId = l.ItemId AND s.LocId = l.LocId 
			INNER JOIN dbo.tblInItem i ON s.ItemId = i.ItemId
			GROUP BY s.ItemId, s.LocId
			
			--capture current non-serialized value
			INSERT INTO #InValue(ItemId, LocId, ExtCost)
			SELECT s.ItemId, s.LocId
				, SUM(CASE WHEN @CostingMethod = 3 THEN ROUND(s.QtyOnHand * l.CostStd, @CurrencyPrecision) ELSE s.Cost END)
			FROM dbo.trav_InItemOnHand_view s 
			INNER JOIN dbo.tblInItemLoc l ON s.ItemId = l.ItemId AND s.LocId = l.LocId 
			GROUP BY s.ItemId, s.LocId
			
			--back out transactions going into Inventory/add in transactions coming out of Inventory
			--	for periods as of or later than the period/year being processed
			INSERT INTO #InValue(ItemId, LocId, ExtCost)
			SELECT ItemId, LocId, SUM(ExtCost) 
				FROM (
					--include value of all quantities
					SELECT d.ItemId, d.LocId
						, SUM(CASE WHEN [Source] < 70 THEN -d.CostExt ELSE d.CostExt End) ExtCost
						FROM dbo.tblInHistDetail d 
						WHERE ((d.SumYear * 1000) + d.GLPeriod) >= @YrPdToProcess AND d.DropShipYn=0
						AND d.[Source] > 0 AND d.[Source] NOT IN (200, 201) AND (d.Qty > 0 OR (d.AppId = 'PO' AND d.Qty = 0 AND d.CostExt <> 0 )) -- Po invoice coversion
						GROUP BY d.ItemId, d.LocId
					UNION All
					--back out value of received quantities that have been invoiced (invoiced qty @ received cost)
					SELECT d.ItemId, d.LocId
						, SUM(CASE WHEN d.[Source] < 70 
							THEN d.Qty * r.CostUnit
							ELSE -(d.Qty * r.CostUnit) End) ExtCost
						FROM dbo.tblInHistDetail d 
						INNER JOIN dbo.tblInHistDetail r ON d.HistSeqNum_Rcpt = r.HistSeqNum
						WHERE ((d.SumYear * 1000) + d.GLPeriod) >= @YrPdToProcess AND d.DropShipYn=0
						GROUP BY d.ItemId, d.LocId
					--include cogsadj
					UNION ALL
					SELECT d.ItemId, d.LocId
						, SUM(d.CostExt) ExtCost
						FROM dbo.tblInHistDetail d 
						WHERE d.[Source] IN (200, 201) AND ((d.SumYear * 1000) + d.GLPeriod) >= @YrPdToProcess AND d.DropShipYn=0
						GROUP BY d.ItemId, d.LocId
				) tmp
				GROUP BY ItemId, LocId
			
			--summarize the valuation by the Inventory GL Account for a beginning balance
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
				, AccountId, TransDate, Amount)
			SELECT 39, 'IN', NULL, NULL, NULL, NULL 
				, a.GLAcctInv, NULL, SUM(t.ExtCost)
			FROM #InValue t 
			INNER JOIN dbo.tblInItemLoc l (NOLOCK) ON t.ItemId = l.ItemId AND t.LocId = l.LocId
			INNER JOIN dbo.tblInGlAcct a ON l.GlAcctCode = a.GlAcctCode
			GROUP BY a.GlAcctInv
		END
	END
	
	------------------------------------------------------
	------------------------- FA -------------------------
	------------------------------------------------------
	If (@AppFlags & 8) = 8
	Begin
		--add FA to the application list
		INSERT INTO #AppList (AppId) VALUES ('FA')
	
		--capture depreciation amounts posted to GL
		--Accumulated Depreciation
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 40, 'FA', h.PostRun, d.AssetID, d.DeprcType, 0
			, ISNULL(h.GLAccumDepr, a.GLAccum), h.TransDate, -h.Amount
		FROM dbo.tblFaAssetDeprActivity h (NOLOCK)
		INNER JOIN dbo.tblFaAssetDepr d (NOLOCK) ON h.DeprID = d.ID
		INNER JOIN dbo.tblFaOptionDepr o (NOLOCK) ON d.DeprcType = o.DeprType
		INNER JOIN dbo.tblFaAsset a (NOLOCK) ON d.AssetID = a.AssetID
		WHERE h.FiscalYear = @FiscalYear AND h.FiscalPeriod = @FiscalPeriod
			AND h.TransType = 0 --only regular depreciation
			AND o.[Type] = 1 --Only 'Book' Types post to GL

	
		IF @BeginningBalance = 1
		BEGIN
			--Capture the total depreciation amounts taken prior to the given period/year
			--Accumulated Depreciation
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
				, AccountId, TransDate, Amount)
			SELECT 49, 'FA', NULL, NULL, NULL, NULL
				, ISNULL(h.GLAccumDepr, a.GLAccum), NULL, SUM(-h.Amount)
			FROM dbo.tblFaAssetDeprActivity h (NOLOCK)
			INNER JOIN dbo.tblFaAssetDepr d (NOLOCK) ON h.DeprID = d.ID
			INNER JOIN dbo.tblFaOptionDepr o (NOLOCK) ON d.DeprcType = o.DeprType
			INNER JOIN dbo.tblFaAsset a (NOLOCK) ON d.AssetID = a.AssetID
			WHERE (h.FiscalYear * 1000) + h.FiscalPeriod < @YrPdToProcess
				AND h.TransType = 0 --only regular depreciation
				AND o.[Type] = 1 --Only 'Book' Types post to GL
			GROUP BY ISNULL(h.GLAccumDepr, a.GLAccum)
		END	

	END


	------------------------- BR -------------------------
	IF (@AppFlags & 16) = 16
	BEGIN

		--add BR to the application list
		INSERT INTO #AppList (AppId) VALUES ('BR')

		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)

		SELECT CASE WHEN TransType=-1 THEN 51
					WHEN TransType=2 THEN 52
					WHEN TransType=-3 THEN 53
					WHEN TransType=4 THEN 54
					END
					,'BR',NULL,m.BankID,m.SourceID,NULL,b.GlCashAcct,m.TransDate
					,CASE	WHEN  (m.Voiddate IS NOT NULL AND (m.VoidYear > @FiscalYear OR ( m.VoidYear =@FiscalYear AND m.VoidPd > @FiscalPeriod)))
							THEN m.VoidAmt 
							ELSE Amount 
					END
		FROM dbo.tblBrMaster m
		INNER JOIN dbo.tblSmBankAcct b ON m.BankID = b.BankId
		WHERE m.FiscalYear = @FiscalYear AND m.GlPeriod = @FiscalPeriod AND b.CurrencyId =@BaseCurrency

		IF @BeginningBalance = 1
		BEGIN
			INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)

			SELECT	 59, 'BR', NULL, NULL, NULL, NULL
					,b.GlCashAcct, NULL,
					 SUM(b.GLAcctBal) - ISNULL(SUM(TransAmount),0)
			FROM  dbo.tblSmBankAcct b
			LEFT JOIN
				(SELECT BankID,	 SUM( AmountFgn) TransAmount
				 FROM dbo.tblBrMaster m					
				 WHERE ((m.FiscalYear * 1000) + m.GlPeriod) >= @YrPdToProcess 
				 GROUP BY BankID
				) m	 ON m.BankID = b.BankId	
			WHERE b.CurrencyId =@BaseCurrency	
			GROUP BY b.GlCashAcct
		END

	END
   
	------------------------------------------------------------------
	--GL Balances - adjust amount based on the BalType (BalType * Amt)
	------------------------------------------------------------------
	--Sum of trans from gl where the account id's exist in
	--	Select DistCode, PayablesGLAcct, SalesTaxGLAcct, FreightGLAcct, MiscGLAcct From tblApDistCode
	--	select DistCode, GLAcctReceivables, GLAcctSalesTax, GLAcctFreight, GLAcctMisc from tblArDistCode
	--	Select GLAcctCode, Descr, GLAcctSales, GLAcctCogs, GLAcctInv, GLAcctWip, GLAcctInvAdj
	--		, GLAcctCogsAdj, GLAcctPurchPriceVar, GLAcctStandCostVar, GLAcctPhyCountAdj, GLAcctXferCost from tblInGlAcct
	--	select GlAsset, GlAccum, GlExpense from tblFaAsset --(doc doesn't include the GlExpense - should we include it?)

	--build list of GL Accts from each app that need to be processed
	If (@AppFlags & 1) = 1
	Begin
		Insert into #AppAccts (AppId, GlAcct, DfltBalType)
		Select 'AP', PayablesGLAcct , -1 --Use Credit Default Balance for AP
			From dbo.tblApDistCode (NOLOCK)
			Where PayablesGlAcct not in (Select GlAcct From #AppAccts)
			Group by PayablesGLAcct

		Insert into #AppAccts (AppId, GlAcct, DfltBalType)
		Select 'AP', DepositGLAcct , -1 --Use Credit Default Balance for AP
			From dbo.tblApDistCode (NOLOCK)
			Where DepositGLAcct not in (Select GlAcct From #AppAccts)
			Group by DepositGLAcct
	End

	If (@AppFlags & 2) = 2
	Begin
		IF @GlAcctCustomerDeposit IS NOT NULL 
		Begin
			Insert into #AppAccts (AppId, GlAcct)
			VALUES ('AR', @GlAcctCustomerDeposit)
		End
		Insert into #AppAccts (AppId, GlAcct)
		Select 'AR', GLAcctReceivables
			From dbo.tblArDistCode (NOLOCK)
			Where GLAcctReceivables not in (Select GlAcct From #AppAccts)
			Group by GLAcctReceivables
	End

	If (@AppFlags & 4) = 4
	Begin
		Insert into #AppAccts (AppId, GlAcct)
		Select 'IN', GLAcctInv
			From dbo.tblInGlAcct (NOLOCK)
			Where GLAcctInv not in (Select GlAcct From #AppAccts)
			Group by GLAcctInv
		
		Insert into #AppAccts (AppId, GlAcct)
		Select 'IN', GLAcctInvAdj
			From dbo.tblInGlAcct (NOLOCK)
			Where GLAcctInvAdj not in (Select GlAcct From #AppAccts)
			Group By GLAcctInvAdj
	END

	If (@AppFlags & 8) = 8
	Begin
		
		Insert into #AppAccts (AppId, GlAcct)
		Select 'FA', GlAccum
			From dbo.tblFaAsset (NOLOCK)
			Where GlAccum not in (Select GlAcct From #AppAccts)
			Group by GlAccum
	End

	-- Only BaseCurrency bank accounts for BR
	If (@AppFlags & 16) = 16
	Begin
		Insert into #AppAccts (AppId, GlAcct)
		Select 'BR',GlCashAcct
			From dbo.tblSmBankAcct(NOLOCK)			
		Where GlCashAcct not in (Select GlAcct From #AppAccts) AND CurrencyId =@BaseCurrency
			Group by GlCashAcct
	End


	--capture the value of current journal entries for the list of accounts
	INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
		, AccountId, TransDate, Amount)
	SELECT 0, t.AppId, j.PostRun, j.LinkID, j.LinkIDSub, j.LinkIDSubLine
	, t.GlAcct, j.TransDate
	, Case When t.DfltBalType = h.BalType 
		Then (Case When h.BalType < 0 Then -(j.DebitAmt - j.CreditAmt) Else (j.DebitAmt - j.CreditAmt) End) 
		ELSE -(Case When h.BalType < 0 Then -(j.DebitAmt - j.CreditAmt) Else (j.DebitAmt - j.CreditAmt) End) 
		END
	FROM #AppAccts t 
	INNER JOIN dbo.tblGlAcctHdr h (NOLOCK) ON t.GlAcct = h.Acctid
	INNER JOIN dbo.tblGlJrnl j (NOLOCK) ON h.AcctId = j.AcctId 
	Where j.[Year] = @FiscalYear AND j.[Period] = @FiscalPeriod
		AND j.URG = 0 -- Exclude unrealized gain/loss journal entries
	
	--capture the beginning balances for the given period/year 
	IF @BeginningBalance = 1
	BEGIN
		--capture the beginning balance from Account Detail (ending balance of prior period)
		--	posted amounts for each GL Account (Period 0 contains the beginning balance for the given year)
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 9, t.AppId, NULL, NULL, NULL, NULL
			, t.GlAcct, NULL, Sum(Case When t.DfltBalType = h.BalType Then d.ActualBase Else -d.ActualBase End) 
		FROM #AppAccts t 
		INNER JOIN dbo.tblGlAcctDtl d ON t.GlAcct = d.AcctId 
		INNER JOIN dbo.tblGlAcctHdr h ON d.AcctId = h.AcctId 
		Where d.[Year] = @FiscalYear and d.Period < @FiscalPeriod
			Group By t.AppId, t.GlAcct

		--back out any posted unrealized gain/loss entries for prior periods
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 9, t.AppId, NULL, NULL, NULL, NULL
		, t.GlAcct, NULL
		, CASE WHEN t.DfltBalType = h.BalType 
			THEN -(CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END) 
			ELSE (CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END) 
			END
		FROM #AppAccts t 
		INNER JOIN dbo.tblGlAcctHdr h (NOLOCK) ON t.GlAcct = h.Acctid
		INNER JOIN dbo.tblGlJrnl j (NOLOCK) ON h.AcctId = j.AcctId 
		Where (j.[Year] * 1000) + j.Period < @YrPdToProcess
			AND j.PostedYn <> 0 -- posted
			AND j.URG = 1 -- Unrealized gain/loss journal entries

		--capture any additional unposted journal entries for prior periods
		INSERT INTO #Audit(SourceType, AppId, PostRun, LinkId, LinkIdSub, LinkIDSubLine
			, AccountId, TransDate, Amount)
		SELECT 9, t.AppId, NULL, NULL, NULL, NULL
		, t.GlAcct, NULL
		, CASE WHEN t.DfltBalType = h.BalType 
			THEN (CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END) 
			ELSE -(CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END) 
			END
		FROM #AppAccts t 
		INNER JOIN dbo.tblGlAcctHdr h (NOLOCK) ON t.GlAcct = h.Acctid
		INNER JOIN dbo.tblGlJrnl j (NOLOCK) ON h.AcctId = j.AcctId 
		Where (j.[Year] * 1000) + j.Period < @YrPdToProcess
			AND j.PostedYn = 0 --unposted
			AND j.URG = 0 -- Exclude unrealized gain/loss journal entries
	END

	--return the results
	SELECT l.AppId, a.SourceType, a.PostRun, a.LinkId, a.LinkIdSub, a.LinkIDSubLine
		, a.AccountId, a.TransDate, SUM(ISNULL(a.Amount, 0)) Amount
		, CASE WHEN a.SourceType < 10 THEN 0 ELSE 1 END AmountType --0=GL/1=Subledger
		, SUM(CASE WHEN a.SourceType < 10 THEN -ISNULL(a.Amount, 0) ELSE ISNULL(a.Amount, 0) END) AS [Value]
		, h.[Desc] AS [Description]
	FROM #AppList l 
	LEFT JOIN #Audit a ON l.AppId = a.AppId
	LEFT JOIN dbo.tblGlAcctHdr h on a.AccountId = h.AcctId
	GROUP BY l.AppId, a.SourceType, a.PostRun, a.LinkId, a.LinkIdSub, a.LinkIDSubLine, a.AccountId, a.TransDate, h.[Desc]

	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlSubsidiaryLedgerAudit_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlSubsidiaryLedgerAudit_proc';


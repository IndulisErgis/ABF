
CREATE PROCEDURE dbo.trav_GlPostToMaster_AccountAlloc_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	
	IF @PostRun IS NULL
		OR (SELECT Count(*) FROM #CurrencyInfo) = 0
	BEGIN
		RAISERROR('Missing global value.', 16, 1)
	END

	--ordered list of allocations to define a reference to the 
	--	highest percentage per allocated account
	CREATE TABLE #AllocationDetail (
		AllocEntryNum INT IDENTITY(1, 1),
		AcctId pGlAcct,
		AllocToAcctId pGlAcct,
		AllocPct pDecimal,
		MaxAllocEntryNum INT,
		UNIQUE CLUSTERED (AcctId, AllocToAcctId),
		UNIQUE NONCLUSTERED (AllocEntryNum)
	)

	--list of allocated journal entries to process
	CREATE TABLE #Journal (
		[EntryNum] int Not Null, 
		[CompId] nvarchar(3) Null, 
		[EntryDate] datetime Null, 
		[TransDate] datetime Null, 
		[PostedYn] smallint Null, 
		[Desc] nvarchar(30) Null, 
		[SourceCode] nvarchar(2) Null, 
		[Reference] nvarchar(255) Null, 
		[AcctId] pGlAcct Not Null, 
		[DebitAmt] pCurrDecimal Null, 
		[CreditAmt] pCurrDecimal Null, 
		[Period] smallint Null, 
		[Year] smallint Null, 
		[AllocateYn] bit Null, 
		[ChkRecon] bit Null, 
		[CashFlow] bit Null, 
		[LinkID] nvarchar(255) Null, 
		[LinkIDSub] nvarchar(15) Null, 
		[LinkIDSubLine] int Null, 
		[PostRun] pPostRun Null, 
		[ExchRate] pDecimal Not Null, 
		[CurrencyID] pCurrency Null, 
		[DebitAmtFgn] pCurrDecimal Not Null, 
		[CreditAmtFgn] pCurrDecimal Not Null, 
		[URG] bit Not Null, 
		UNIQUE CLUSTERED (EntryNum)
	)

	--list for processing the allocation amounts
	CREATE TABLE #AllocationAmounts (
		EntryNum INT, 
		AllocEntryNum INT,
		CreditAmt pCurrDecimal,
		DebitAmt pCurrDecimal,
		CreditAmtFgn pCurrDecimal,
		DebitAmtFgn pCurrDecimal,
		UNIQUE CLUSTERED (EntryNum, AllocEntryNum)
	)

	--populate the ordered list of #AllocationDetail
	INSERT INTO #AllocationDetail (AcctId, AllocToAcctId, AllocPct)
	SELECT AcctId, AllocToAcctId, AllocPct
	FROM dbo.tblGlAllocDtl
	ORDER BY AllocPct

	--exit if no entries exist
	IF @@RowCount = 0 RETURN

	--identify the Allocation Detail with the highest percentage
	UPDATE #AllocationDetail Set MaxAllocEntryNum = s.MaxAllocEntryNum
	FROM (SELECT AcctId, Max(AllocEntryNum) MaxAllocEntryNum
		FROM #AllocationDetail
		GROUP BY AcctId) s
	WHERE #AllocationDetail.AcctId = s.AcctId
	

	--capture a list of allocated journal entries to process
	INSERT INTO #Journal (EntryNum, CompId, EntryDate, TransDate, PostedYn, [Desc]
		, SourceCode, Reference, AcctId, DebitAmt, CreditAmt
		, Period, [Year], AllocateYn, ChkRecon, CashFlow
		, LinkID, LinkIDSub, LinkIDSubLine, PostRun, ExchRate
		, CurrencyID, DebitAmtFgn, CreditAmtFgn, URG)
	SELECT j.EntryNum, j.CompId, j.EntryDate, j.TransDate, j.PostedYn, j.[Desc]
		, j.SourceCode, j.Reference, j.AcctId, j.DebitAmt, j.CreditAmt
		, j.Period, j.[Year], j.AllocateYn, j.ChkRecon, j.CashFlow
		, j.LinkID, j.LinkIDSub, j.LinkIDSubLine, j.PostRun, j.ExchRate
		, j.CurrencyID, j.DebitAmtFgn, j.CreditAmtFgn, j.URG
	FROM dbo.tblGlJrnl j
	INNER JOIN dbo.tblGlAllocHdr a on j.AcctId = a.AcctId
	INNER JOIN #PostJournalList l ON j.EntryNum = l.EntryNum 
	WHERE  j.AllocateYn = 1
		
	--exit if no entries exist
	IF @@RowCount = 0 RETURN
	

	--calcualte the allocated amounts for each account
	INSERT INTO #AllocationAmounts (EntryNum, AllocEntryNum, CreditAmt, DebitAmt, CreditAmtFgn, DebitAmtFgn)
	SELECT j.EntryNum, a.AllocEntryNum
		, ROUND(j.CreditAmt * (a.AllocPct * .01), ISNULL(c.[Precision], 2)) 
		, ROUND(j.DebitAmt * (a.AllocPct * .01), ISNULL(c.[Precision], 2))
		, ROUND(j.CreditAmtFgn * (a.AllocPct * .01), ISNULL(c.[Precision], 2)) 
		, ROUND(j.DebitAmtFgn * (a.AllocPct * .01), ISNULL(c.[Precision], 2))
	FROM #Journal j
	INNER JOIN #AllocationDetail a on j.AcctId = a.AcctId
	LEFT JOIN #CurrencyInfo c on j.CurrencyId = c.CurrencyId


	--adjust the allocation amount with the largest percentage to account for 
	--	any rounding variances due to the currency precision
	UPDATE #AllocationAmounts 
	Set CreditAmt = (j.CreditAmt - s.AllocCreditAmt)
		, DebitAmt = (j.DebitAmt - s.AllocDebitAmt)
		, CreditAmtFgn = (j.CreditAmtFgn - s.AllocCreditAmtFgn)
		, DebitAmtFgn = (j.DebitAmtFgn - s.AllocDebitAmtFgn)
	FROM #Journal j 
	INNER JOIN (SELECT a.EntryNum, d.MaxAllocEntryNum
		, SUM(CreditAmt) AllocCreditAmt, SUM(DebitAmt) AllocDebitAmt
		, SUM(CreditAmtFgn) AllocCreditAmtFgn, SUM(DebitAmtFgn) AllocDebitAmtFgn
		FROM #AllocationAmounts a
		INNER JOIN #AllocationDetail d on a.AllocEntryNum = d.AllocEntryNum
		WHERE a.AllocEntryNum < d.MaxAllocEntryNum
		GROUP BY a.EntryNum, d.MaxAllocEntryNum) s
	ON j.EntryNum = s.EntryNum
	WHERE #AllocationAmounts.EntryNum = j.EntryNum
		AND #AllocationAmounts.AllocEntryNum = s.MaxAllocEntryNum
	
	
	--create a journal entry to reverse the allocated entry (flip credit and debit amounts)
	INSERT dbo.tblGlJrnl (PostRun, EntryDate, TransDate, [Desc], CompId
		, SourceCode, Reference, AcctID, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CurrencyId, DebitAmtFgn, CreditAmtFgn, ExchRate )
	SELECT @PostRun, j.EntryDate, j.TransDate, j.[Desc], j.CompId
		, 'AL', Convert(nvarchar(15), j.EntryNum), j.AcctId, j.CreditAmt, j.DebitAmt, j.Period, j.[Year]
		, 0, j.ChkRecon, j.CurrencyId, j.CreditAmtFgn, j.DebitAmtFgn, j.ExchRate
	FROM #Journal j


	--create journal entries for the allocated amounts
	INSERT dbo.tblGlJrnl (PostRun, EntryDate, TransDate, [Desc], CompId
		, SourceCode, Reference, AcctID, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CurrencyId, DebitAmtFgn, CreditAmtFgn, ExchRate )
	SELECT @PostRun, j.EntryDate, j.TransDate, j.[Desc], j.CompId
		, 'AL', Convert(nvarchar(15), j.EntryNum), d.AllocToAcctId, a.DebitAmt, a.CreditAmt, j.Period, j.[Year]
		, 0, j.ChkRecon, j.CurrencyId, a.DebitAmtFgn, a.CreditAmtFgn, j.ExchRate
	FROM #Journal j
	INNER JOIN #AllocationAmounts a on j.EntryNum = a.EntryNum
	INNER JOIN #AllocationDetail d on a.AllocEntryNum = d.AllocEntryNum


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_AccountAlloc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_AccountAlloc_proc';


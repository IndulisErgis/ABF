
CREATE PROCEDURE dbo.trav_GlPostToMaster_CompanyAlloc_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @curCompId cursor, @CompId [sysname]
	DECLARE @SegType nvarchar(2), @SegNumber INT, @Start INT, @Len INT
	DECLARE @PostRun pPostRun

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'

	IF @PostRun IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	Create table #CompAllocList(
		EntryNum int,
		ToCompId [nvarchar](3),
		AcctIdDebit pGlAcct, 
		AcctIdCredit pGlAcct,
		PRIMARY KEY (EntryNum)
	)

	Create table #CompAllocJrnl(
		[CompId] [nvarchar] (3) NULL ,
		[EntryDate] [datetime] NULL ,
		[TransDate] [datetime] NULL ,
		[Desc] [nvarchar] (30) NULL ,
		[SourceCode] [nvarchar] (2) NULL ,
		[Reference] [nvarchar] (255) NULL ,
		[AcctId] [pGlAcct] NOT NULL ,
		[DebitAmt] [pCurrDecimal] NULL  DEFAULT (0),
		[CreditAmt] [pCurrDecimal] NULL DEFAULT (0),
		[Period] [smallint] NULL DEFAULT (0),
		[Year] [smallint] NULL DEFAULT (0),
		[AllocateYn] [bit] NULL DEFAULT (1),
		[ChkRecon] [bit] NULL DEFAULT (0),
		[CashFlow] [bit] NULL DEFAULT (1),
		[LinkID] [nvarchar] (255) NULL ,
		[LinkIDSub] [nvarchar] (15) NULL ,
		[LinkIDSubLine] [int] NULL DEFAULT (0) ,
		[PostRun] [pPostRun] NULL Default (0),
		[CurrencyId] [pCurrency] NOT NULL,
		[ExchRate] [pDecimal] NULL DEFAULT (1),
		[DebitAmtFgn] [pCurrDecimal] NULL  DEFAULT (0),
		[CreditAmtFgn] [pCurrDecimal] NULL DEFAULT (0)
	)
	Create index [IX_CompAllocJrnl_CompId] on #CompAllocJrnl (CompId)


	--exit if the segment type is not defined or no company allocations exist
	SELECT TOP 1 @SegType = SegType FROM dbo.tblGlAllocCompDtl
	IF @SegType IS NULL RETURN 

	--create a list of journal entries to process
	IF ISNUMERIC(@SegType) = 1
	BEGIN
		SELECT @SegNumber = CAST(@SegType as INT)

		SELECT @Start = BeginLength + 1, @Len = SegLength
		FROM (SELECT SUM(Case When Number < @SegNumber THEN [Length] ELSE 0 END) BeginLength
				, SUM(Case When Number = @SegNumber THEN [Length] ELSE 0 END) SegLength
				FROM dbo.tblGlAcctMaskSegment
				WHERE Number <= @SegNumber
		) s

		--create the list using a partial (single segment) match for each entry in tblGlAllocCompDtl
		INSERT INTO #CompAllocList(EntryNum, ToCompId, AcctIdDebit, AcctIdCredit)
		SELECT j.EntryNum, a.ToCompId, a.AcctIdDebit, a.AcctIdCredit
		FROM dbo.tblGlJrnl j
		INNER JOIN dbo.tblGlAllocCompDtl a ON SUBSTRING(j.AcctId, @Start, @Len) = a.SegId
		INNER JOIN #PostJournalList l ON j.EntryNum = l.EntryNum 
	END
	ELSE
	BEGIN
		--create a list using a full account match for each entry in tblGlAllocCompDtl
		INSERT INTO #CompAllocList(EntryNum, ToCompId, AcctIdDebit, AcctIdCredit)
		SELECT j.EntryNum, a.ToCompId, a.AcctIdDebit, a.AcctIdCredit
		FROM dbo.tblGlJrnl j
		INNER JOIN dbo.tblGlAllocCompDtl a ON j.AcctId = a.SegId
		INNER JOIN #PostJournalList l ON j.EntryNum = l.EntryNum 
	END


	--create reversal entries for the current company (swap the debit/credit amt)
	INSERT INTO #CompAllocJrnl (CompId, EntryDate, TransDate, [Desc], SourceCode
		, Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine
		, PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT j.CompId, j.EntryDate, j.TransDate, 'Transfer to Company ' + l.ToCompId, j.SourceCode
		, j.Reference, j.AcctId, j.CreditAmt, j.DebitAmt, j.Period, j.[Year]
		, j.AllocateYn, j.ChkRecon, j.CashFlow, j.LinkID, j.LinkIDSub, j.LinkIDSubLine
		, @PostRun, j.CurrencyId, j.ExchRate, j.CreditAmtFgn, j.DebitAmtFgn
	FROM dbo.tblGlJrnl j inner join #CompAllocList l on j.EntryNum = l.EntryNum

	--create the current company clearing account ('Transfer To') Journal entries (always offsets to the "debit" account - the current-comp account)
	INSERT INTO #CompAllocJrnl (CompId, EntryDate, TransDate, [Desc], SourceCode
		, Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine
		, PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT j.CompId, j.EntryDate, j.TransDate, 'Transfer to Company ' + l.ToCompId, j.SourceCode
		, j.Reference, l.AcctIdDebit, j.DebitAmt, j.CreditAmt, j.Period, j.[Year]
		, j.AllocateYn, j.ChkRecon, j.CashFlow, j.LinkID, j.LinkIDSub, j.LinkIDSubLine
		, @PostRun, j.CurrencyId, j.ExchRate, j.DebitAmtFgn, j.CreditAmtFgn
	FROM dbo.tblGlJrnl j inner join #CompAllocList l on j.EntryNum = l.EntryNum

	--create the destination company Journal entries (copy current company to other company)
	INSERT INTO #CompAllocJrnl (CompId, EntryDate, TransDate, [Desc], SourceCode
		, Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine
		, PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT l.ToCompId, j.EntryDate, j.TransDate, j.[Desc], j.SourceCode
		, j.Reference, j.AcctId, j.DebitAmt, j.CreditAmt, j.Period, j.[Year]
		, j.AllocateYn, j.ChkRecon, j.CashFlow, j.LinkID, j.LinkIDSub, j.LinkIDSubLine
		, @PostRun, j.CurrencyId, j.ExchRate, j.DebitAmtFgn, j.CreditAmtFgn
	FROM dbo.tblGlJrnl j inner join #CompAllocList l on j.EntryNum = l.EntryNum

	--create the destination company clearing account ('Transfer From') Journal entries (always offsets to the "Creit" account - the alt-comp account)
	INSERT INTO #CompAllocJrnl (CompId, EntryDate, TransDate, [Desc], SourceCode
		, Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]
		, AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine
		, PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
	SELECT l.ToCompId, j.EntryDate, j.TransDate, 'Transfer From Company ' + j.CompId, j.SourceCode
		, j.Reference, l.AcctIdCredit, j.CreditAmt, j.DebitAmt, j.Period, j.[Year]
		, j.AllocateYn, j.ChkRecon, j.CashFlow, j.LinkID, j.LinkIDSub, j.LinkIDSubLine
		, @PostRun, j.CurrencyId, j.ExchRate, j.CreditAmtFgn, j.DebitAmtFgn
	FROM dbo.tblGlJrnl j inner join #CompAllocList l on j.EntryNum = l.EntryNum


	--create Journal entries for each company
	Set @curCompId = Cursor for Select CompId From #CompAllocJrnl Group By CompId
	Open @curCompId
	If @@Cursor_rows <> 0
	Begin
		Fetch next from @curCompId Into @CompId
		While @@Fetch_status = 0
		Begin
			Exec ('INSERT INTO [' + @CompId + '].dbo.tblGlJrnl (CompId'
				+ ', EntryDate, TransDate, PostedYn, [Desc], SourceCode'
				+ ', Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]'
				+ ', AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine'
				+ ', PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)'
				+ ' Select CompId, EntryDate, TransDate, 0, [Desc], SourceCode'
				+ ', Reference, AcctId, DebitAmt, CreditAmt, Period, [Year]'
				+ ', AllocateYn, ChkRecon, CashFlow, LinkID, LinkIDSub, LinkIDSubLine'
				+ ', PostRun, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn'
				+ ' From #CompAllocJrnl'
				+ ' Where CompId = ''' + @CompId + '''')

			Fetch next from @curCompId into @CompId
		End
		
		Close @curCompId
	End
	Deallocate @curCompId
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_CompanyAlloc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPostToMaster_CompanyAlloc_proc';


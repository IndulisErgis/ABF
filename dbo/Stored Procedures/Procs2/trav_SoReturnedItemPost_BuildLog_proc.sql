
CREATE PROCEDURE dbo.trav_SoReturnedItemPost_BuildLog_proc
AS
SET NOCOUNT ON

--PET:http://webfront:801/view.php?id=229231
--PET:http://webfront:801/view.php?id=236794

BEGIN TRY
	DECLARE	@PostRun pPostRun
	, @FiscalPeriod smallint
	, @FiscalYear smallint
	, @SumGlDescrInv nvarchar(30) 
	, @SumGlDescrCOGS nvarchar(30)
	, @ArGlDetailYn bit
	, @CurrBase pCurrency
	, @CompId [sysname]     
	, @WrkStnDate datetime


	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @SumGlDescrInv = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'SumGlDescrInv'
	SELECT @SumGlDescrCOGS = Cast([Value] AS nvarchar(30)) FROM #GlobalValues WHERE [Key] = 'SumGlDescrCOGS'
	SELECT @ArGlDetailYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ArGlDetailYn'
	SELECT @CurrBase = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	
	IF @PostRun IS NULL OR @FiscalPeriod IS NULL OR @FiscalYear IS NULL
		OR @SumGlDescrInv IS NULL OR @SumGlDescrCOGS IS NULL
		OR @ArGlDetailYn IS NULL OR @CurrBase IS NULL 
		OR @WrkStnDate IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #ReturnedItemGlEntries
	(
		[Counter] [INT] Identity(1, 1) ,
		[PostRun] [pPostRun] , 
		[TransId] [pTransId] ,
		[EntryNum] [INT] ,
		[Amount] [pDecimal] NOT NULL ,
		[TransDate] [datetime] NULL ,
		[PostDate] [datetime] NULL ,
		[SourceCode] [nvarchar] (2) NULL ,
		[Reference] [nvarchar] (15) NULL ,
		[FiscalYear] [smallint] NULL ,
		[FiscalPeriod] [smallint] NULL ,
		[Grouping] [smallint] NULL ,
		[Descr] [nvarchar] (30) NULL ,
		[SummaryDescr] [nvarchar] (30) NULL,
		[GlAcct] [nvarchar] (40) NULL ,
		[LinkID] [nvarchar] (15) NULL ,
		[LinkIDSub] [nvarchar] (15) NULL ,
		[LinkIDSubLine] [int] NULL ,
		[DR] [pDecimal] NULL ,
		[CR] [pDecimal] NULL
	)

	DECLARE @RMAPrefix nvarchar(4)
	SELECT @RMAPrefix = Right(Convert(nvarchar, @WrkStnDate, 12), 4)

	--capture a snapshot of records being processed
	Insert into #ReturnedItemLog(PostRun, RICtrRef, RMANumber
		, CustId, TransDate, TransId, EntryNum
		, ItemId, LocId, ExtLocA, ExtLocB, QtyReturn, Units, LotNum, SerNum
		, UnitCost, CostExt, UnitPrice, PriceExt, QtySeqNum
		, GlAcctCOGS, GlAcctInv
		, ItemDescription, ExtLocAId, [ExtLocBId])
	SELECT @PostRun, r.[Counter], ISNULL(r.RMANumber, @RMAPrefix + r.TransID)
		, r.CustId, r.TransDate, r.TransId, r.EntryNum
		, r.ItemId, r.LocId, r.ExtLocA, r.ExtLocB, r.QtyReturn, r.Units, r.LotNum, r.SerNum
		, r.UnitCost, r.CostExt, r.UnitPrice, r.PriceExt, r.QtySeqNum
		, r.GlAcctCOGS, r.GlAcctInv, i.Descr, a.ExtLocID AS ExtLocAId, b.ExtLocID AS ExtLocBId 
	FROM dbo.tblSoReturnedItem r
		LEFT JOIN dbo.tblInItem i ON r.ItemId = i.ItemId 
		LEFT JOIN dbo.tblWmExtLoc a ON r.ExtLocA = a.Id 
		LEFT JOIN dbo.tblWmExtLoc b ON r.ExtLocB = b.Id 
	INNER JOIN #PostTransList l on r.[Counter] = l.[TransId]
	
	
	--build entries for the GL log
	--	Inventory Account
	INSERT #ReturnedItemGlEntries (PostRun, TransId, EntryNum
		, Amount, Transdate, PostDate, SourceCode, Reference
		, FiscalYear, FiscalPeriod, [Grouping], Descr, SummaryDescr
		, GlAcct, LinkID, LinkIDSub, LinkIDSubLine, DR, CR)    
	SELECT @PostRun, TransId, EntryNum
		, CostExt, TransDate, @WrkStnDate, 'SO', CustId
		, @FiscalYear, @FiscalPeriod, 11, SUBSTRING(RMANumber + ' / ' + ItemID, 1, 30), @SumGlDescrInv
		, GLAcctInv, TransID, EntryNum, -8
		, CASE WHEN CostExt > 0 THEN ABS(CostExt) ELSE 0 END
		, CASE WHEN CostExt < 0 THEN ABS(CostExt) ELSE 0 END
	FROM #ReturnedItemLog
	WHERE CostExt <> 0

	--	COGS Account 
	INSERT #ReturnedItemGlEntries (PostRun, TransId, EntryNum
		, Amount, Transdate, PostDate, SourceCode, Reference
		, FiscalYear, FiscalPeriod, [Grouping], Descr, SummaryDescr
		, GlAcct, LinkID, LinkIDSub, LinkIDSubLine, DR, CR)
	SELECT @PostRun, TransId, EntryNum
		, -CostExt, TransDate, @WrkStnDate, 'SO', CustId
		, @FiscalYear, @FiscalPeriod, 12, SUBSTRING(RMANumber + ' / ' + ItemID, 1, 30), @SumGlDescrCOGS
		, GLAcctCOGS, TransID, EntryNum, -8
		, CASE WHEN -CostExt > 0 THEN ABS(CostExt) ELSE 0 END
		, CASE WHEN -CostExt < 0 THEN ABS(CostExt) ELSE 0 END
	FROM #ReturnedItemLog
	WHERE CostExt <> 0

	--populate the GL Log table
	IF (@ArGlDetailYn = 0)
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId, LinkIDSubLine)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, Sum(DR + CR), 'SO', SummaryDescr
			, Sum(DR), Sum(CR), Sum(DR), Sum(CR)
			, SourceCode, PostDate, PostDate, @CurrBase, 1, @CompId, -8
		FROM #ReturnedItemGlEntries 
		GROUP BY PostRun, PostDate, SummaryDescr, SourceCode, GlAcct, FiscalPeriod, FiscalYear, [Grouping]
		HAVING SUM(DR) <> 0 OR SUM(CR) <> 0
	ELSE
		INSERT #GlPostLogs (PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAccount, AmountFgn, Reference, [Description]
			, DebitAmount, CreditAmount, DebitAmountFgn, CreditAmountFgn
			, SourceCode, PostDate, TransDate, CurrencyId, ExchRate, CompId
			, LinkID, LinkIDSub, LinkIDSubLine)
		SELECT PostRun, FiscalYear, FiscalPeriod, [Grouping]
			, GlAcct, (DR + CR), Reference, Descr
			, DR, CR, DR, CR
			, 'SO', PostDate, TransDate, @CurrBase, 1, @CompId
			, LinkID, LinkIDSub, LinkIDSubLine
		FROM #ReturnedItemGlEntries


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_BuildLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoReturnedItemPost_BuildLog_proc';


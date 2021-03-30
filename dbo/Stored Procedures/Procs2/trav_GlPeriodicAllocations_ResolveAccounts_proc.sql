
CREATE PROCEDURE dbo.trav_GlPeriodicAllocations_ResolveAccounts_proc
AS
SET NOCOUNT ON
BEGIN TRY
	----Expects the list of group ids to process to be provided via temp table #GroupIDList
	--Create Table #GroupIDList (
	--	[GroupID] [bigint] not null ,
	--	Primary Key ([GroupID])
	--)

	----populates the list of resolved account information in temp table #ResolvedAccounts
	----	includes the relative status values for the resolved allocation groups and allocation codes for logging
	--Create Table #ResolvedAccounts (
	--	[GroupID] [bigint] ,
	--	[CalcStatus] [int] , --0;valid;<>0;invalid
	--	[DetailType] [tinyint] , --0;Source;1;Recipient
	--	[Status] [tinyint] , --0=valid/1=Invalid/2=non-active/8=invalid acct/16=inactive acct
	--	[CodeID] [bigint] , 
	--	[CodeSequence] [bigint] , 
	--	[CodeSegSequence] [bigint] , 
	--	[CodeDetailSequence] [bigint] , 
	--	[DistType] [tinyint] , --Distribution Type Enum:0=Full;1=Partial
	--	[AllocBasis] [tinyint] , --Allocation Basis Enum:0=Fixed;1=Weighted;2=Average Balance
	--	[SegmentId] [nvarchar](12) , 
	--	[AltSegmentId] [nvarchar](12) , 
	--	[AccountId] [pGlAcct] , 
	--	[BalanceType] [smallint] , --enum:-1;Credit;0;Memo;1;Debit
	--	[AltAccountId] [pGlAcct] , 
	--	[AltBalanceType] [smallint] , --enum:-1;Credit;0;Memo;1;Debit
	--	[AllocType] [tinyint] , --0;NA;1;Amount;2;Percentage
	--	[AllocAmount] [pDecimal] , 
	--	[AllocLimit] [pDecimal]
	--)

	Declare @TransDate datetime

	--Retrieve global values
	SELECT @TransDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'TransDate'
	
	IF @TransDate IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END


	--build the list of positional segment information
	Create Table #SegmentInfo (
		[Number] [int] not null ,
		[Start] [int] not null , 
		[Length] [int] not null
	)

	Insert into #SegmentInfo ([Number], [Length], [Start])
	Select [Number], [Length]
		, isnull((Select Sum([Length]) From dbo.tblGlAcctMaskSegment s (NOLOCK)	Where s.Number < t.Number), 0) + 1 AS [Start]
		From dbo.tblGlAcctMaskSegment t (NOLOCK)

	--Step 1/2/3: Resolve accounts 

	--Step 1/2/3(a): Capture full account detail
	Insert into #ResolvedAccounts ([GroupID], [CalcStatus], [Status]
		, [DetailType], [CodeID], [CodeSequence], [CodeSegSequence], [CodeDetailSequence]
		, [DistType], [AllocBasis], [SegmentId], [AltSegmentId], [AccountId], [AltAccountId]
		, [AllocType], [AllocAmount], [AllocLimit])
	Select gh.[ID]
		, Case When gh.[Status] <> 0 or gh.[EffectiveDate] > @TransDate or gh.[ExpirationDate] <= @TransDate Then 128 Else 0 End --identify groups that are invalid
			+ Case When pc.[Status] <> 0 or pc.[EffectiveDate] > @TransDate or pc.[ExpirationDate] <= @TransDate Then 256 Else 0 End --identify codes that are invalid
		, 0, pd.[DetailType], gc.[AllocCodeID], gc.[Sequence], 0, pd.[Sequence]
		, pc.[DistType], pc.[AllocBasis], NULL, NULL, pd.[AccountID], ISNULL(pd.[AltAccountID], pd.[AccountID])
		, ISNULL(pd.[AllocType], 0), ISNULL(pd.[AllocAmount], 0), ISNULL(pd.[AllocLimit], 0)
		From dbo.tblGlAllocPdGroup gh 
		Inner Join #GroupIDList tg on gh.[ID] = tg.[GroupID]
		Inner Join dbo.tblGlAllocPdGroupCode gc on gh.[ID] = gc.[AllocGroupID]
		Inner Join dbo.tblGlAllocPdCode pc on gc.[AllocCodeID] = pc.[ID]
		Inner Join dbo.tblGlAllocPdCodeDetail pd on pc.[ID] = pd.[AllocCodeID]
		WHERE (pc.[SourceType] = 0 AND pd.[DetailType] = 0) OR (pc.[RecipientType] = 0 AND pd.[DetailType] = 1) --Full Account ID source/recipient

	--Step 1/2/3(b): Capture segment based detail (Source)
	Insert into #ResolvedAccounts ([GroupID], [CalcStatus], [Status]
		, [DetailType], [CodeID], [CodeSequence], [CodeSegSequence], [CodeDetailSequence]
		, [DistType], [AllocBasis], [SegmentId], [AltSegmentId], [AccountId], [AltAccountId]
		, [AllocType], [AllocAmount], [AllocLimit])
	Select gh.[ID]
		, Case When gh.[Status] <> 0 or gh.[EffectiveDate] > @TransDate or gh.[ExpirationDate] <= @TransDate Then 128 Else 0 End --identify groups that are invalid
			+ Case When pc.[Status] <> 0 or pc.[EffectiveDate] > @TransDate or pc.[ExpirationDate] <= @TransDate Then 256 Else 0 End --identify codes that are invalid
		, 0, ps.[DetailType], gc.[AllocCodeID], gc.[Sequence], ps.[Sequence], pd.[Sequence]
		, pc.[DistType], pc.[AllocBasis], ps.[SegmentID], ISNULL(ps.[AltSegmentID], ps.[SegmentID]) 
		, STUFF(pd.[AccountID], si.[Start], si.[Length], ps.[SegmentID])
		, STUFF(ISNULL(pd.[AltAccountID], pd.[AccountID]), si.[Start], si.[Length], ISNULL(ps.[AltSegmentID], ps.[SegmentID]))
		, COALESCE(NULLIF(pd.[AllocType], 0), ps.[AllocType], 0) --use segment value when detail is null or zero
		, Case When NULLIF(pd.[AllocType], 0) IS NULL --use segment when detail type is null or zero or detail amount is zero and types match
			Then ISNULL(ps.[AllocAmount], 0) 
			Else Case When (NULLIF(pd.[AllocAmount], 0) IS NULL And ISNULL(pd.[AllocType], 0) = ISNULL(ps.[AllocType], 0))
				Then ISNULL(ps.[AllocAmount], 0)
				Else ISNULL(pd.[AllocAmount], 0)
				End
			End
		, COALESCE(NULLIF(pd.[AllocLimit], 0), ps.[AllocLimit], 0) --use segment value when detail is null or zero
		From dbo.tblGlAllocPdGroup gh 
		Inner Join #GroupIDList tg on gh.[ID] = tg.[GroupID]
		Inner Join dbo.tblGlAllocPdGroupCode gc on gh.[ID] = gc.[AllocGroupID]
		Inner Join dbo.tblGlAllocPdCode pc on gc.[AllocCodeID] = pc.[ID]
		Inner Join dbo.tblGlAllocPdCodeSegment ps on pc.[ID] = ps.[AllocCodeID]
		Inner Join dbo.tblGlAllocPdCodeDetail pd on ps.[AllocCodeID] = pd.[AllocCodeID] and ps.[DetailType] = pd.[DetailType] --cross join between Segment and Detail
		Inner Join #SegmentInfo si on pc.[SourceType] = si.[Number] --link SourceType to Segment 
		WHERE (pc.[SourceType] > 0 AND pd.[DetailType] = 0) --Segment based source

	--Step 1/2/3(b): Capture segment based detail (Recipient)
	Insert into #ResolvedAccounts ([GroupID], [CalcStatus], [Status]
		, [DetailType], [CodeID], [CodeSequence], [CodeSegSequence], [CodeDetailSequence]
		, [DistType], [AllocBasis], [SegmentId], [AltSegmentId], [AccountId], [AltAccountId]
		, [AllocType], [AllocAmount], [AllocLimit])
	Select gh.[ID]
		, Case When gh.[Status] <> 0 or gh.[EffectiveDate] > @TransDate or gh.[ExpirationDate] <= @TransDate Then 128 Else 0 End --identify groups that are invalid
			+ Case When pc.[Status] <> 0 or pc.[EffectiveDate] > @TransDate or pc.[ExpirationDate] <= @TransDate Then 256 Else 0 End --identify codes that are invalid
		, 0, ps.[DetailType], gc.[AllocCodeID], gc.[Sequence], ps.[Sequence], pd.[Sequence]
		, pc.[DistType], pc.[AllocBasis], ps.[SegmentID], ISNULL(ps.[AltSegmentID], ps.[SegmentID]) 
		, STUFF(pd.[AccountID], si.[Start], si.[Length], ps.[SegmentID])
		, STUFF(ISNULL(pd.[AltAccountID], pd.[AccountID]), si.[Start], si.[Length], ISNULL(ps.[AltSegmentID], ps.[SegmentID]))
		, COALESCE(NULLIF(pd.[AllocType], 0), ps.[AllocType], 0)  --use segment value when detail is null or zero
		, Case When NULLIF(pd.[AllocType], 0) IS NULL --use segment when detail type is null or zero or detail amount is zero and types match
			Then ISNULL(ps.[AllocAmount], 0) 
			Else Case When (NULLIF(pd.[AllocAmount], 0) IS NULL And ISNULL(pd.[AllocType], 0) = ISNULL(ps.[AllocType], 0))
				Then ISNULL(ps.[AllocAmount], 0)
				Else ISNULL(pd.[AllocAmount], 0)
				End
			End
		, COALESCE(NULLIF(pd.[AllocLimit], 0), ps.[AllocLimit], 0) --use segment value when detail is null or zero
		From dbo.tblGlAllocPdGroup gh 
		Inner Join #GroupIDList tg on gh.[ID] = tg.[GroupID]
		Inner Join dbo.tblGlAllocPdGroupCode gc on gh.[ID] = gc.[AllocGroupID]
		Inner Join dbo.tblGlAllocPdCode pc on gc.[AllocCodeID] = pc.[ID]
		Inner Join dbo.tblGlAllocPdCodeSegment ps on pc.[ID] = ps.[AllocCodeID]
		Inner Join dbo.tblGlAllocPdCodeDetail pd on ps.[AllocCodeID] = pd.[AllocCodeID] and ps.[DetailType] = pd.[DetailType] --cross join between Segment and Detail
		Inner Join #SegmentInfo si on pc.[RecipientType] = si.[Number] --link RecipientType to Segment 
		WHERE (pc.[RecipientType] > 0 AND pd.[DetailType] = 1) --Segment based recipient


	--Setp 1/2/3(c): Invalidate resolved accounts that are invalid/non-active (0=valid/1=Invalid/2=non-active/8=invalid acct/16=inactive acct)
	Update #ResolvedAccounts 
		Set #ResolvedAccounts.[Status] = Case When h.[AcctID] IS NULL Then 8 Else 16 End
			, #ResolvedAccounts.[CalcStatus] = Case When h.[AcctID] IS NULL Then 8 Else 16 End
		From #ResolvedAccounts s 
		Left Join dbo.tblGlAcctHdr h on s.[AccountId] = h.[AcctID]
		Where s.[Status] = 0 and (h.[AcctID] IS NULL or h.[Status] <> 0)

	--Step 1/2/3(d-source): Replace invalid/non-active Offset accounts with the source account for any valid accounts
	Update #ResolvedAccounts Set #ResolvedAccounts.[AltAccountId] = s.[AccountId]
		From #ResolvedAccounts s 
		Left Join dbo.tblGlAcctHdr h on s.[AltAccountId] = h.[AcctID]
		Where s.[DetailType] = 0 and s.[Status] = 0 and (h.[AcctID] IS NULL or h.[Status] <> 0)

	--Step 1/2/3(d-recipient): Reset invalid Basis accounts to exclude their use in calculations (ok to use non-active accounts)
	Update #ResolvedAccounts Set #ResolvedAccounts.[AltAccountId] = NULL
			, #ResolvedAccounts.[AltBalanceType] = 0
		From #ResolvedAccounts s 
		Left Join dbo.tblGlAcctHdr h on s.[AltAccountId] = h.[AcctID]
		Where s.[DetailType] = 1 and h.[AcctID] IS NULL

	--Capture supplemental account information (AccountId)
	Update #ResolvedAccounts Set [BalanceType] = h.[BalType]
		From #ResolvedAccounts 
		Inner Join dbo.tblGlAcctHdr h on #ResolvedAccounts.[AccountId] = h.[AcctId]

	--Capture supplemental account information (AltAccountId)
	Update #ResolvedAccounts Set [AltBalanceType] = h.[BalType]
		From #ResolvedAccounts 
		Inner Join dbo.tblGlAcctHdr h on #ResolvedAccounts.[AltAccountID] = h.[AcctId]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocations_ResolveAccounts_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocations_ResolveAccounts_proc';



CREATE PROCEDURE dbo.trav_GlPeriodicAllocation_AccountBalances_proc
AS
SET NOCOUNT ON
BEGIN TRY
	----expects temp table #ResolvedAccounts to exist with the minimum schema
	--Create Table #ResolvedAccounts (
	--	[CalcStatus] [int] , --0;valid;<>0;invalid
	--	[DetailType] [tinyint] , --0;Source;1;Recipient
	--	[AllocBasis] [tinyint] , --Allocation Basis Enum:0=Fixed;1=Weighted;2=Average Balance
	--	[AccountId] [pGlAcct], 
	--	[AltAccountId] [pGlAcct] , 
	--)

	Declare @SourceType tinyint
	Declare @SourceFiscalYear smallint
	Declare @SourceFiscalPeriodFrom smallint
	Declare @SourceFiscalPeriodThru smallint
	Declare @BasisType tinyint
	Declare @BasisFiscalYear smallint
	Declare @BasisFiscalPeriodFrom smallint
	Declare @BasisFiscalPeriodThru smallint

	--Retrieve global values
	SELECT @SourceType = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'SourceType'
	SELECT @SourceFiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'SourceFiscalYear'
	SELECT @SourceFiscalPeriodFrom = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'SourceFiscalPeriodFrom'
	SELECT @SourceFiscalPeriodThru = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'SourceFiscalPeriodThru'
	SELECT @BasisType = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'BasisType'
	SELECT @BasisFiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalYear'
	SELECT @BasisFiscalPeriodFrom = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalPeriodFrom'
	SELECT @BasisFiscalPeriodThru = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalPeriodThru'

	IF (@SourceType IS NULL or @SourceFiscalYear IS NULL 
		or @SourceFiscalPeriodFrom IS NULL or @SourceFiscalPeriodThru IS NULL
		or @BasisType IS NULL or @BasisFiscalYear IS NULL 
		or @BasisFiscalPeriodFrom IS NULL or @BasisFiscalPeriodThru IS NULL)
	BEGIN
		RAISERROR(90025,16,1)
	END

	--Step 4/5: Capture/Evaluate Account Amounts
	Create Table #AcctBalance (
		[AccountID] [pGlAcct] ,
		[Type] [tinyint] not null , --ENUM:0;Source;1;Basis;2;AvgDailyStart
		[BalanceBase] [pDecimal]
	)

	--identify the accounts for which a balance is needed
	Create Table #AcctBalanceIDList (
		[AccountID] pGlAcct , 
		[Type] [tinyint] not null , --ENUM:0;Source;1;Basis;2;AvgDailyStart
		[FiscalYear] [smallint] not null ,
		[FiscalPeriodFrom] [smallint] not null ,
		[FiscalPeriodThru] [smallint] not null ,
		Primary Key ([AccountID], [Type], [FiscalYear], [FiscalPeriodFrom], [FiscalPeriodThru])
	)

	--Capture accounts and needed ranges for each balance type needed
	--Source Accounts
	Insert Into #AcctBalanceIDList ([AccountID], [Type], [FiscalYear], [FiscalPeriodThru], [FiscalPeriodFrom])
	Select [AccountID], 0, @SourceFiscalYear, @SourceFiscalPeriodThru
		, Case When @SourceType = 0 Then 0 Else @SourceFiscalPeriodFrom End
	From #ResolvedAccounts 
	Where [CalcStatus] = 0  and [DetailType] = 0 
	Group By [AccountId]

	--Recipient basis accounts using weighted basis
	Insert Into #AcctBalanceIDList ([AccountID], [Type], [FiscalYear], [FiscalPeriodThru], [FiscalPeriodFrom])
	Select [AltAccountID], 1, @BasisFiscalYear, @BasisFiscalPeriodThru
		, Case When @BasisType = 0 Then 0 Else @BasisFiscalPeriodFrom End
	From #ResolvedAccounts 
	Where [CalcStatus] = 0 and [DetailType] = 1 And [AllocBasis] = 1 and [AltAccountID] is not null
	Group By [AltAccountID]

	--Recipient basis accounts using average balance basis - period beginning balance
	Insert Into #AcctBalanceIDList ([AccountID], [Type], [FiscalYear], [FiscalPeriodThru], [FiscalPeriodFrom])
	Select [AltAccountID], 2, @BasisFiscalYear, Case When @BasisType = 0 Then 0 Else @BasisFiscalPeriodFrom - 1 End, 0
	From #ResolvedAccounts 
	Where [CalcStatus] = 0 and [DetailType] = 1 And [AllocBasis] = 2 and [AltAccountID] is not null
	Group By [AltAccountID]


	--Capture type specific account balances for the period range
	--	(Unposted entries prior to the given year must be posted to master)
	Insert into #AcctBalance ([AccountID], [Type], [BalanceBase])
	Select l.[AccountID], l.[Type], SUM(ISNULL(d.[ActualBase], 0))
		From #AcctBalanceIDList l 
		Left Join dbo.tblGlAcctDtl d on l.[AccountID] = d.[AcctId]
		Where d.[AcctId] is null --include placeholder for accounts without detail
			OR (d.[Year] = l.[FiscalYear] 
				And d.[Period] >= l.[FiscalPeriodFrom] 
				And d.[Period] <= l.[FiscalPeriodThru]) 
		Group By l.[AccountID], l.[Type]

	--Adjust the balances for unposted journal entries within the period range
	--	(Unposted entries prior to the given year must be posted to master)
	Insert into #AcctBalance ([AccountID], [Type], [BalanceBase])
	Select j.[AcctId], l.[Type]
		, SUM(CASE WHEN d.[BalType] < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END)
		From dbo.tblGlJrnl j
		Inner Join #AcctBalanceIDList l on j.[AcctId] = l.[AccountID]
		Inner Join dbo.tblGlAcctHdr d ON j.AcctId = d.AcctId 
		Where (j.PostedYn = 0) 
			And j.[Year] = l.[FiscalYear] 
			And j.[Period] >= l.[FiscalPeriodFrom]
			And j.[Period] <= l.[FiscalPeriodThru]
		Group By j.[AcctId], l.[Type]


	--return the per type balances
	Select [AccountID], [Type], SUM([BalanceBase]) AS [BalanceBase]
		From #AcctBalance
		Group By [AccountID], [Type]

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocation_AccountBalances_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocation_AccountBalances_proc';


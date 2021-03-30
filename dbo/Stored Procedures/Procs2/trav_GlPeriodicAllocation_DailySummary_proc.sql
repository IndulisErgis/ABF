
CREATE PROCEDURE dbo.trav_GlPeriodicAllocation_DailySummary_proc
AS
SET NOCOUNT ON
BEGIN TRY
	----expects temp table #ResolvedAccounts to exist with the minimum schema
	--Create Table #ResolvedAccounts (
	--	[CalcStatus] [int] , --0;valid;<>0;invalid
	--	[DetailType] [tinyint] , --0;Source;1;Recipient
	--	[AllocBasis] [tinyint] , --Allocation Basis Enum:0=Fixed;1=Weighted;2=Average Balance
	--	[AltAccountId] [pGlAcct]
	--)

	Declare @BasisType tinyint
	Declare @BasisFiscalYear smallint
	Declare @BasisFiscalPeriodFrom smallint
	Declare @BasisFiscalPeriodThru smallint
	Declare @TransDate datetime
	Declare @TransFiscalPeriod smallint
	Declare @TransFiscalYear smallint

	--Retrieve global values
	SELECT @BasisType = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'BasisType'
	SELECT @BasisFiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalYear'
	SELECT @BasisFiscalPeriodFrom = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalPeriodFrom'
	SELECT @BasisFiscalPeriodThru = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'BasisFiscalPeriodThru'
	SELECT @TransDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'TransDate'
	SELECT @TransFiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'TransFiscalPeriod'
	SELECT @TransFiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'TransFiscalYear'

	IF (@BasisType IS NULL or @BasisFiscalYear IS NULL 
		or @BasisFiscalPeriodFrom IS NULL or @BasisFiscalPeriodThru IS NULL
		or @TransDate IS NULL or @TransFiscalPeriod IS NULL or @TransFiscalYear IS NULL)
	BEGIN
		RAISERROR(90025,16,1)
	END

	Declare @BasisYearPdFrom int
	Declare @BasisYearPdThru int
	
	--Start at the beginning of the year when BasisType = Balance (0)
	Select @BasisYearPdFrom = (@BasisFiscalYear * 1000) + Case When @BasisType = 0 Then 1 Else @BasisFiscalPeriodFrom End
		, @BasisYearPdThru = (@BasisFiscalYear * 1000) + @BasisFiscalPeriodThru

	Create Table #DailyTransSummary (
		[AccountID] [pGlAcct] ,
		[TransDate] [datetime] not null ,
		[FiscalPeriod] [smallint] not null ,
		[FiscalYear] [smallint] not null , 
		[AmountBase] [pDecimal] ,
		[NextDate] [datetime] null ,
		Primary Key ([AccountID], [TransDate])
	)

	--identify the accounts for which a balance is needed
	Create Table #DailyAcctIDList (
		[AccountID] pGlAcct ,
		Primary Key ([AccountID])
	)

	Insert Into #DailyAcctIDList ([AccountID])
	Select Distinct [AltAccountID]
		From #ResolvedAccounts 
		Where [CalcStatus] = 0 and [DetailType] = 1 And [AllocBasis] = 2 and [AltAccountID] is not null --recipient basis accounts using average balance basis

	--evaluate summary data when accounts exist
	if @@ROWCOUNT <> 0
	Begin
		--aggregate transactions by day, realign trans date with fiscal period as needed
		Insert into #DailyTransSummary ([AccountId], [FiscalPeriod], [FiscalYear]
			, [AmountBase], [TransDate])
		Select j.[AcctId], j.[Period], j.[Year]
			, SUM(CASE WHEN d.[BalType] < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END) as [AmountBase]
			, Case When j.[TransDate] < pc.[BegDate] Then pc.[BegDate] Else Case When j.[TransDate] > pc.[EndDate] Then pc.[EndDate] Else j.[TransDate] End End as [TransDate]
			From dbo.tblGlJrnl j
			Inner Join dbo.tblGlAcctHdr d ON j.AcctId = d.AcctId 
			Inner Join #DailyAcctIDList l on d.[AcctId] = l.[AccountID]
			Inner join dbo.tblSmPeriodConversion pc on j.[Year] = pc.[GlYear] and j.[Period] = pc.[GlPeriod]
			Where (j.[Year] * 1000) + j.[Period] >= @BasisYearPdFrom And (j.[Year] * 1000) + j.[Period] <= @BasisYearPdThru
			Group By j.[AcctId], j.[Period], j.[Year] 
			, pc.[BegDate], pc.[EndDate] 
			, Case When j.[TransDate] < pc.[BegDate] Then pc.[BegDate] Else Case When j.[TransDate] > pc.[EndDate] Then pc.[EndDate] Else j.[TransDate] End End

		--include a placeholder for the beginning date for the starting period
		Declare @StartYearPdBeginDate datetime
		Select @StartYearPdBeginDate = j.[BegDate]
			From dbo.tblSmPeriodConversion j 
			Where (j.[GlYear] * 1000) + j.[GlPeriod] = @BasisYearPdFrom

		Insert into #DailyTransSummary ([AccountId], [FiscalPeriod], [FiscalYear]
			, [AmountBase], [TransDate])
		Select t.[AccountID], @BasisFiscalPeriodFrom, @BasisFiscalYear, 0, @StartYearPdBeginDate
			From #DailyAcctIDList t
			Where t.[AccountID] not in (
				Select [AccountID] 
				From #DailyTransSummary s 
				Where s.TransDate = @StartYearPdBeginDate
			) --avoid duplicate entries

		--conditionally include a placeholder for generated transactions to use for DayCount evaluation
		If (((@TransFiscalYear * 1000) + @TransFiscalPeriod) >= @BasisYearPdFrom And ((@TransFiscalYear * 1000) + @TransFiscalPeriod) <= @BasisYearPdThru)
		Begin
			Declare @TempDate datetime

			Select @TempDate = Case When @TransDate < pc.[BegDate] Then pc.[BegDate] 
				Else Case When @TransDate > pc.[EndDate] Then pc.[EndDate] Else @TransDate End End 
				From dbo.tblSmPeriodConversion pc 
				Where pc.[GlYear] = @TransFiscalYear and pc.[GlPeriod] = @TransFiscalPeriod

			Insert into #DailyTransSummary ([AccountId], [FiscalPeriod], [FiscalYear]
				, [AmountBase], [TransDate])
			Select l.[AccountID], @TransFiscalPeriod, @TransFiscalYear, 0, @TempDate
				From #DailyAcctIDList l 
				Left Join (Select [AccountId] From #DailyTransSummary Where [TransDate] = @TempDate) b on l.[AccountID] = b.[AccountID]
				Where b.[AccountID] is null --avoid duplicate entries
		End

		Declare @EndingDate datetime
		Select @EndingDate = Dateadd(d, 1, j.[EndDate])
			From dbo.tblSmPeriodConversion j 
			Where (j.[GlYear] * 1000) + j.[GlPeriod] = @BasisYearPdThru

		--evaluate the daycount between transactions
		--	use the day after the period ending date of the AsOf period for the last transaction
		Update #DailyTransSummary Set [NextDate] = Isnull(b.[NextTransDate], @EndingDate)
			From (Select s.[AccountId], s.[TransDate]
				, (Select Min([TransDate])
					From #DailyTransSummary nb 
					Where nb.[AccountID] = s.[AccountID] and nb.[TransDate] > s.[TransDate]) As [NextTransDate]
				From #DailyTransSummary s) b
			Where #DailyTransSummary.[AccountID] = b.[AccountID] and #DailyTransSummary.[TransDate] = b.[TransDate]
	End

	--return the results
	Select [AccountID], [TransDate], [FiscalPeriod], [FiscalYear], [AmountBase], DateDiff(d, [TransDate], [NextDate]) AS [DayCount]
		From #DailyTransSummary

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocation_DailySummary_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlPeriodicAllocation_DailySummary_proc';


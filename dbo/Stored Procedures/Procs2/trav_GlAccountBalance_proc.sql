
CREATE PROCEDURE dbo.trav_GlAccountBalance_proc
@SysDB sysname
AS
BEGIN TRY
	Set Nocount on
	--PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=12818
	--PET:http://traversedev.internal.osas.com:8090/pets/view.php?id=12919
	--PET:http://webfront:801/view.php?id=227616
	--PET:http://webfront:801/view.php?id=231845
	--PET:http://webfront:801/view.php?id=238926
	--PET:http://webfront:801/view.php?id=230815
	
	--establish temp table for building the data
	CREATE TABLE #AccountAmounts (
		AmountType tinyint, --0=Actual/1=BudgetForecast/3=EndingBalance/4=Activity
		AcctId pGlAcct,
		FiscalYear smallint,
		FiscalPeriod smallint,
		Amount pCurrDecimal null,
		ActualBase pCurrDecimal null,
		Balance pCurrDecimal null,
		Budget pCurrDecimal null,
		Forecast pCurrDecimal null,
		BFRef int,
		BFAcctDtlRef int,
		Value pCurrDecimal null, --signed value of Amount
		ValueBase pCurrDecimal null --signed value of Actual Base
	)

	CREATE NONCLUSTERED INDEX [IX_AccountAmounts] ON #AccountAmounts ([AmountType], [AcctId], [FiscalYear], [FiscalPeriod], [BFRef])	


	CREATE TABLE #BFDescr (
		BFRef int,
		Descr nvarchar(30)
		CONSTRAINT [PK_BFDescr] PRIMARY KEY NONCLUSTERED ([BFRef])	
	)


	--Account detail amounts
	Insert into #AccountAmounts (AmountType, AcctId, FiscalYear, FiscalPeriod
		, Amount, ActualBase, Balance, Budget, Forecast, BFRef, BFAcctDtlRef
		, Value, ValueBase)
	Select 0 , d.[AcctId], d.[Year], d.[Period]
		, d.[Actual], d.[ActualBase], d.[Balance], d.[Budget], d.[Forecast], NULL, NULL
		, d.[Actual], d.[ActualBase]
	From dbo.tblGlAcctDtl d
	Inner Join #AccountYearPeriodList a on d.[AcctId] = a.[AcctId] and d.[Year] = a.[FiscalYear] and d.[Period] = a.[FiscalPeriod]
	Where d.[Actual] <> 0 or d.[ActualBase] <> 0 
		or d.[Balance] <> 0 or d.[Budget] <> 0 or d.[Forecast] <> 0


	--Account activity amounts
	Insert into #AccountAmounts (AmountType, AcctId, FiscalYear, FiscalPeriod
		, Amount
		, ActualBase
		, Balance, Budget, Forecast, BFRef, BFAcctDtlRef
		, Value, ValueBase)
	Select 4, j.[AcctId], j.[Year], j.[Period]
		, SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END)
		, SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END)
		, NULL, NULL, NULL, NULL, NULL
		, SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmtFgn - j.CreditAmtFgn) ELSE (j.DebitAmtFgn - j.CreditAmtFgn) END)
		, SUM(CASE WHEN h.BalType < 0 THEN -(j.DebitAmt - j.CreditAmt) ELSE (j.DebitAmt - j.CreditAmt) END)
	From dbo.tblGlJrnl j
	Inner Join dbo.tblGlAcctHdr h on j.[AcctId] = h.[AcctId]
	Inner Join #AccountYearPeriodList a on j.[AcctId] = a.[AcctId] and j.[Year] = a.[FiscalYear] and j.[Period] = a.[FiscalPeriod]
	Where j.[PostedYn] = 0 
	Group By j.AcctId, j.[Year], j.Period
	Having SUM(j.DebitAmtFgn - j.CreditAmtFgn) <> 0 OR SUM(j.DebitAmt - j.CreditAmt) <> 0


	--Ending Balance (Detail + Activity)
	Insert into #AccountAmounts (AmountType, AcctId, FiscalYear, FiscalPeriod
		, Amount, ActualBase, Balance, Budget, Forecast, BFRef, BFAcctDtlRef)
	Select 3, l.AcctId, l.FiscalYear, l.FiscalPeriod
		, SUM(ISNULL(a.Value, 0)), SUM(ISNULL(a.ValueBase, 0)), NULL, NULL, NULL, NULL, NULL
	From #AccountYearPeriodList l
	Left Join #AccountAmounts a on l.AcctId = a.AcctId 
	Where l.[AcctId] = a.[AcctId] AND l.[FiscalPeriod] >= a.[FiscalPeriod] AND l.[FiscalYear] = a.[FiscalYear]
	Group By l.[AcctId], l.[FiscalYear], l.[FiscalPeriod] 
	
	
	--Budget/Forecast amounts
	Insert into #AccountAmounts (AmountType, AcctId, FiscalYear, FiscalPeriod
		, Amount, ActualBase, Balance, Budget, Forecast, BFRef, BFAcctDtlRef)
	Select 1, b.[AcctId], b.[GlYear], b.[GlPeriod]
		, b.[Amount], NULL, NULL, NULL, NULL, b.[BFRef], b.[BFAcctDtlRef]
	From dbo.tblGlAcctDtlBudFrcst b
	Inner Join #AccountYearPeriodList a on b.[AcctId] = a.[AcctId] and b.[GlYear] = a.[FiscalYear] and b.[GlPeriod] = a.[FiscalPeriod]
	Where b.[Amount] <> 0


	--retrieve the Budget/Forecast descriptions from the system database
	EXEC('Insert into #BFDescr (BFRef, Descr) Select BFRef, Descr From [' + @SysDb + '].dbo.tblGlBudFrcstDescr')


	--return the results
	Select p.[AcctId], p.[Desc], p.[AcctTypeId], CASE WHEN p.[BalType] > 0 THEN 'Debit' WHEN p.[BalType] = 0   THEN 'Memo' ELSE 'Credit' End AS BalType, p.[ClearToAcct], p.[ClearToStep]
		, p.[ConsolToAcct], p.[ConsolToStep], p.[Status], p.[CurrencyID]
		, t.[Desc] AS [AccountTypeDescription], t.[AcctClassId], t.[AcctCode]
		, l.[FiscalYear] AS [Year], l.[FiscalPeriod] AS [Period], isnull(dtl.[AmountType], 3) AS [AmountType]
		, Case isnull(dtl.AmountType, 3) When 0 Then 'Actual' When 1 Then s.Descr When 3 Then 'Actual (Ending Balance)' When 4 Then 'Activity Amount' Else 'NA' End [AmountDescription]
		, dtl.[Amount], dtl.[BFRef], dtl.[ActualBase], dtl.[Balance], dtl.[Budget], dtl.[Forecast], dtl.[BFAcctDtlRef]
	From dbo.trav_tblGlAcctHdr_view p
	Inner join #AccountYearPeriodList l on p.AcctId = l.AcctId
	Left Join #AccountAmounts dtl on l.AcctId = dtl.AcctId and l.FiscalYear = dtl.FiscalYear and l.FiscalPeriod = dtl.FiscalPeriod
	Left Join dbo.tblGlAcctType t on p.[AcctTypeId] = t.[AcctTypeId] 
	Left Join #BFDescr s on dtl.BFRef = s.BFRef

	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountBalance_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlAccountBalance_proc';


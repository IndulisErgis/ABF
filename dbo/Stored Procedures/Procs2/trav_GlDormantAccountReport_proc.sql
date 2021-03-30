
CREATE PROCEDURE dbo.trav_GlDormantAccountReport_proc
@FiscalPeriod smallint, 
@FiscalYear smallint, 
@SortOrder nvarchar(80) = '1,2,3'

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @sql nvarchar(1100)
	DECLARE @SortString nvarchar(255)
	DECLARE @ctr smallint

	CREATE TABLE #InactiveAccounts
	(
		AcctId pGlAcct NOT NULL, 
		AccountDescr nvarchar(30) NULL, 
		CurrencyId pCurrency, 
		TypeDescr nvarchar(30) NULL, 
		ClassDescr nvarchar(30) NULL
	)

	CREATE TABLE #AccountBalances
	(
		AcctId pGlAcct NOT NULL, 
		AccountBalance pCurrDecimal NOT NULL DEFAULT(0)
	)

	-- build a list of active accounts w/ no activity since selected fiscal period/year
	INSERT INTO #InactiveAccounts (AcctId, AccountDescr, CurrencyId, TypeDescr, ClassDescr) 
	SELECT m.AcctId, h.[Desc] AS AccountDescr, h.CurrencyId, t.[Desc] AS TypeDescr, s.[Desc] AS ClassDescr 
	FROM #tmpAccountList m 
		INNER JOIN dbo.tblGlAcctHdr h ON m.AcctId = h.AcctId 
		LEFT JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId 
		LEFT JOIN dbo.tblGlAcctClass s ON t.AcctClassId = s.AcctClassId 
	WHERE h.[Status] = 0 
		AND m.AcctId NOT IN 
			(
				SELECT AcctId FROM dbo.tblGlJrnl 
				WHERE ([Year] = @FiscalYear AND Period > @FiscalPeriod) OR ([Year] > @FiscalYear) GROUP BY AcctId
				UNION
				SELECT AcctId FROM dbo.tblGlJrnlHist 
				WHERE ([Year] = @FiscalYear AND Period > @FiscalPeriod) OR ([Year] > @FiscalYear) GROUP BY AcctId
			)

	-- build a list of account balances for accounts w/ no activity since selected fiscal period/year
	INSERT INTO #AccountBalances (AcctId, AccountBalance) 
	SELECT i.AcctId, SUM(Actual) AS AccountBalance 
	FROM #InactiveAccounts i 
		INNER JOIN dbo.tblGlAcctDtl d ON d.AcctId = i.AcctId 
	WHERE d.[Year] = @FiscalYear AND d.Period <= @FiscalPeriod 
	GROUP BY i.AcctId

	-- build the sort order field list
	SET @SortString = 'h.AcctId'
	IF @SortOrder <> ''
	BEGIN
		SET @SortString = ''

		WHILE CHARINDEX(',', @SortOrder) <> 0
		BEGIN
			SET @ctr = CHARINDEX(',', @SortOrder)
			IF LEN(@SortString) > 0 SET @SortString = @SortString + ' + '
			SET @SortString = @SortString + 'h.Segment' + SUBSTRING(@SortOrder, 1, @ctr - 1)
			SET @SortOrder = RIGHT(@SortOrder, LEN(@SortOrder) - @ctr )
		END
		SET @SortString = @SortString + ' + h.Segment' + @SortOrder
	END

	-- build a list of dynamically defined sort values
	Create Table #SortValue(AcctId pGlAcct, SortOrder nvarchar(MAX))
	
	SET @sql = 'INSERT INTO #SortValue (AcctId, SortOrder)'
		+ ' SELECT h.AcctId, ' + @SortString
		+ ' FROM dbo.trav_GlAccountHeader_view h (NOLOCK)'
		+ ' INNER JOIN #InactiveAccounts t ON h.AcctId = t.AcctId'
	EXECUTE (@sql)

	-- return the results
 	SELECT i.AcctId, i.AccountDescr, i.CurrencyId, i.TypeDescr, i.ClassDescr
 		, ISNULL(b.AccountBalance, 0) AS AccountBalance, s.SortOrder 
 	FROM #InactiveAccounts i 
 		LEFT JOIN #AccountBalances b ON b.AcctId = i.AcctId 
		INNER JOIN #SortValue s ON s.AcctId = i.AcctId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlDormantAccountReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlDormantAccountReport_proc';



CREATE PROCEDURE dbo.trav_GlUpdateFiscalYear_Update_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @FiscalYear smallint, @AcctId pGlAcct, @Consolidate bit, @ClearUnclosedIncome bit, @ClosingPeriod smallint

	--Retrieve global values
	SELECT @FiscalYear = CAST([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @AcctId = CAST([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'AccountId'
	SELECT @Consolidate = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Consolidate'
	SELECT @ClearUnclosedIncome = CAST([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ClearUnclosedIncome'
	SELECT @ClosingPeriod = CAST ([Value] AS smallint) FROM #GlobalValues WHERE [KEY] = 'ClosingPeriod' 

	IF @FiscalYear IS NULL OR @Consolidate IS NULL 
		OR @ClearUnclosedIncome IS NULL OR @ClosingPeriod IS NULL OR (ISNULL(@Consolidate, 0) = 1 AND @AcctId IS NULL) --AcctId only needed when consolidating
	BEGIN
		RAISERROR(90025,16,1)
	END

	--use a temp table to capture last year balances
	CREATE TABLE #LastYearBalance
	(
		AcctId pGlAcct,
		CCAcctId pGlAcct,
		LyActual pCurrDecimal,
		LyActualBase pCurrDecimal, 
		ClearToExist bit, 
		AcctIdBalType smallint, 
		CCAcctIdBalType smallint, 
		CCAcctTypeId smallint
	)

	--insert all the entries into temp table
	INSERT INTO #LastYearBalance (AcctId, CCAcctId, LyActual, LyActualBase, ClearToExist, AcctIdBalType, CCAcctIdBalType)
	SELECT h.AcctId 
		, [AccounttId] = CASE  WHEN @ClearUnclosedIncome = 1 
							   THEN CASE WHEN h.ClearToAcct IS NULL THEN h.AcctId 
										 WHEN h.ClearToAcct ='' THEN h.AcctId		            
										 ELSE h.ClearToAcct END
							   ELSE h.AcctId END
		, SUM(d.Actual) AS LyActual, SUM(d.ActualBase) AS LyActualBase
		, CASE WHEN @ClearUnclosedIncome = 1 AND ISNULL(h.ClearToAcct, '') <> '' THEN 1 ELSE 0 END AS ClearToExist
		, 1 AS AcctIdBalType
		, 1 AS CCAcctIdBalType
		FROM dbo.tblGlAcctHdr h 
		INNER JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 
		WHERE d.[Year] = (@FiscalYear - 1) 
		GROUP BY h.AcctId, h.ClearToAcct

	--Update AcctIdBalType
	Update #LastYearBalance SET AcctIdBalType = h.BalType 
		FROM #LastYearBalance l 
		INNER JOIN  dbo.tblGlAcctHdr h  ON h.AcctId = l.AcctId 
		WHERE  h.AcctId = l.AcctId

	--Update CCAcctIdBalType
	Update #LastYearBalance SET CCAcctIdBalType = h.BalType, CCAcctTypeId = h.AcctTypeId 
		FROM #LastYearBalance l 
		INNER JOIN  dbo.tblGlAcctHdr h  ON h.AcctId = l.CCAcctId 
		WHERE  h.AcctId = l.CCAcctId

	--create any missing beginning balance records
	INSERT INTO dbo.tblGlAcctDtl ([AcctId], [Year], [Period], [Actual], [ActualBase], [Budget], [Forecast], [Balance])
	SELECT h.AcctId, @FiscalYear, 0, 0, 0, 0, 0, 0
	FROM dbo.tblGlAcctHdr h
	WHERE NOT EXISTS (SELECT AcctId FROM dbo.tblGlAcctDtl WHERE [AcctId] = h.[AcctId] And [Year] = @FiscalYear AND [Period] = 0)	

	--zero the account balances for all accounts
	UPDATE dbo.tblGlAcctDtl SET Actual = 0, ActualBase = 0
		FROM dbo.tblGlAcctHdr h 
		INNER JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId
		WHERE [Year] = @FiscalYear AND Period = 0 AND AcctTypeId < 900

	-- Update LyActual, LyActualBase
	UPDATE #LastYearBalance SET LyActual = CASE WHEN AcctIdBalType = CCAcctIdBalType THEN LyActual ELSE LyActual * -1 END, 
		LyActualBase = CASE WHEN AcctIdBalType = CCAcctIdBalType THEN LyActualBase ELSE LyActualBase * -1 END

	--conditionally consolidate unclosed income into the retained earnings account
	IF @Consolidate = 1
	BEGIN
		DECLARE @BalanceBase pCurrDecimal
		DECLARE @BalType smallint
		DECLARE @IncomeBase pCurrDecimal
		DECLARE @Description pDescription

		--copy balances of all balance sheet accounts (0-499) and accounts with clear to
		UPDATE dbo.tblGlAcctDtl SET Actual = t.LyearActual, ActualBase = t.LyearActualBase
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 
			INNER JOIN 
				(
					SELECT CCAcctId, LyearActual = SUM(LyActual), LyearActualBase = SUM(LyActualBase) 
					FROM #LastYearBalance WHERE (CCAcctTypeId < 500 OR ClearToExist = 1) GROUP BY CCAcctId
				) t ON h.AcctID = t.CCAcctId
			WHERE d.[Year] = @FiscalYear AND d.Period = 0

		--retrieve the current unclosed income
			   SELECT @IncomeBase = ISNULL(SUM(CASE WHEN h.AcctTypeId > 599 
													THEN 0 
													ELSE CASE WHEN BalType = -1 
																THEN t.LyearActualBase
																ELSE -t.LyearActualBase 
														 END
											END), 0) -- Revenue
							   - ISNULL(SUM(CASE WHEN h.AcctTypeId < 600 
													THEN 0 
													ELSE CASE WHEN BalType = -1 
																THEN -t.LyearActualBase		
																ELSE t.LyearActualBase
														 END 
											END), 0) -- Expenses
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN (
						 SELECT CCAcctId, SUM(d.[ActualBase]) AS [LyearActualBase], d.[Period] AS [FiscalPeriod], d.[Year] AS [FiscalYear]
							 FROM #LastYearBalance ly
							 INNER JOIN dbo.tblGlAcctDtl d ON ly.[AcctId] = d.[AcctId] --join to account detail via the original account id to get per period amounts for last year
							 WHERE d.[Year] = (@FiscalYear - 1) AND ly.ClearToExist = 0 --filter for last year without a Clear To account 
							 GROUP BY ly.CCAcctId, d.[Period], d.[Year]
                       ) t ON h.AcctID = t.CCAcctId --join to subquery using the clear to account for conditional processing
			WHERE h.AcctTypeId BETWEEN 500 AND 899 --AND t.FiscalYear = (@FiscalYear - 1) AND t.ClearToExist = 0 --filtering done within subquery

		--set the sign of the income based upon the retained earning account balance type
		SELECT @BalType = h.BalType, @Description = h.[Desc]
			, @IncomeBase = CASE WHEN h.BalType = 1 THEN -@IncomeBase ELSE @IncomeBase END 
			FROM dbo.tblGlAcctHdr h 
			WHERE h.AcctId = @AcctId

		--calcuate the new retained earnings balance (Last year balance + Unclosed Income)
		SELECT @BalanceBase = SUM(b.LyActualBase)
			FROM #LastYearBalance b 
			WHERE b.CCAcctId = @AcctId
			GROUP BY B.CCAcctId 

		SELECT @BalanceBase =  ISNULL(@BalanceBase, 0) + @IncomeBase

		--update the retained earning balances
		UPDATE dbo.tblGlAcctDtl SET Actual = @BalanceBase, ActualBase = @BalanceBase
			WHERE [Year] = @FiscalYear AND Period = 0 AND AcctId = @AcctId
	END
	ELSE
	BEGIN
		--copy balances of all accounts
		UPDATE dbo.tblGlAcctDtl SET Actual = t.LyearActual, 
								ActualBase = t.LyearActualBase
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d ON h.AcctId = d.AcctId 
			INNER JOIN (SELECT CCAcctId, LyearActual = SUM(LyActual), LyearActualBase = SUM(LyActualBase) FROM #LastYearBalance GROUP BY CCAcctId) t ON h.AcctID = t.CCAcctId
			WHERE d.[Year] = @FiscalYear AND d.Period = 0 AND h.AcctTypeId < 900
	END

	--create log entries for the balance updates (RecordType = 0)
	INSERT INTO #UpdateFiscalYearLog (RecordType, AccountId, FiscalYear
		, [Description], BalanceType, Amount, CreditAmount, DebitAmount)
	SELECT 0, h.AcctId, @FiscalYear
		, h.[Desc], h.BalType, t.LyActualBase
		, CASE WHEN SIGN(t.CCAcctIdBalType) * t.LyActualBase > 0 THEN ABS(t.LyActualBase) ELSE 0 END
		, CASE WHEN SIGN(t.CCAcctIdBalType) * t.LyActualBase < 0 THEN ABS(t.LyActualBase) ELSE 0 END
	FROM dbo.tblGlAcctHdr h 
	INNER JOIN #LastYearBalance t ON h.AcctID = t.AcctID
	WHERE h.AcctTypeID BETWEEN 500 AND 899

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUpdateFiscalYear_Update_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlUpdateFiscalYear_Update_proc';


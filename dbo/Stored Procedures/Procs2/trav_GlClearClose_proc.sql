
CREATE PROCEDURE dbo.trav_GlClearClose_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @PostRun pPostRun, @WrkStnDate datetime, @CompId [sysname]
	DECLARE @FiscalPeriod smallint, @FiscalYear smallint, @StepFrom tinyint, @StepThru tinyint

	--Retrieve global values
	SELECT @CompId = DB_Name()
	SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @FiscalPeriod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalPeriod'
	SELECT @FiscalYear = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'FiscalYear'
	SELECT @StepFrom = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepFrom'
	SELECT @StepThru = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'StepThru'

	IF @PostRun IS NULL OR @WrkStnDate IS NULL 
		OR @FiscalPeriod IS NULL OR @FiscalYear IS NULL OR @StepFrom IS NULL OR @StepThru IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	DECLARE @Steps smallint, @EntryDate datetime
	SELECT @Steps = @StepFrom
	SELECT @EntryDate = CAST(CONVERT(nvarchar, GETDATE(), 112) AS datetime) -- strip out the time from GetDate

	--Temporarily activate gl accounts that are not active to allow Journal entries to be created
	CREATE TABLE #tmpGlAcct(AcctId pGlAcct, [Status] tinyint)

	INSERT INTO #tmpGlAcct(AcctId, [Status])
	SELECT AcctId, [Status]
	FROM dbo.tblGlAcctHdr
	WHERE [Status] <> 0 
		AND ClearToAcct IS NOT NULL 
		AND ClearToStep BETWEEN @StepFrom AND @StepThru

	UPDATE dbo.tblGlAcctHdr SET Status = 0 
	WHERE AcctId IN (SELECT AcctId FROM #tmpGlAcct)

	--process each step
	WHILE @Steps <= @StepThru
	BEGIN
		-- debit revenue account if Actual is positive (BalType = -1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, DebitAmt, Period, [Year], AllocateYn, CurrencyID, DebitAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.AcctID
				, SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = -1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.AcctID, h.CurrencyID 
			HAVING SUM(d.ActualBase) > 0 OR SUM(d.Actual) > 0


		-- credit revenue account if Actual is negative (BalType = -1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, CreditAmt, Period, [Year], AllocateYn, CurrencyID, CreditAmtFgn, ExchRate)
			 SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.AcctID
				, -SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, -SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.BalType = -1 
				AND h.ClearToAcct IS NOT NULL 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.AcctID, h.CurrencyID 
			HAVING SUM(d.ActualBase) < 0 OR SUM(d.Actual) < 0


		-- credit 'Clear to' account if Actual is positive (BalType = -1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, CreditAmt, Period, [Year], AllocateYn, CurrencyID, CreditAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.ClearToAcct
				, SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = -1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.ClearToAcct, h.CurrencyID 
			HAVING SUM(d.ActualBase) > 0 OR SUM(d.Actual) > 0


		-- debit 'Clear to' account if Actual is negative (BalType = -1)
		 INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, DebitAmt, Period, [Year], AllocateYn, CurrencyID, DebitAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.ClearToAcct
				, -SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, -SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = -1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.ClearToAcct, h.CurrencyID 
			HAVING SUM(d.ActualBase) < 0 OR SUM(d.Actual) < 0


		-- credit expense account if Actual is positive (BalType = 1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, CreditAmt, Period, [Year], AllocateYn, CurrencyID, CreditAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.AcctID
				, SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = 1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.AcctID, h.CurrencyID 
			HAVING SUM(d.ActualBase) > 0 OR SUM(d.Actual) > 0

		-- debit expense account if Actual is negative (BalType = 1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, AcctID
			, DebitAmt, Period, [Year], AllocateYn, CurrencyID, DebitAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL',  h.AcctID
				, -SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, -SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = 1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.AcctID, h.CurrencyID 
			HAVING SUM(d.ActualBase) < 0 OR SUM(d.Actual) < 0


		-- debit 'Clear to' account if Actual is positive (BalType = 1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, 
			AcctID, DebitAmt, Period, [Year], AllocateYn, CurrencyID, DebitAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.ClearToAcct
				, SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = 1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.ClearToAcct, h.CurrencyID 
			HAVING SUM(d.ActualBase) > 0 OR SUM(d.Actual) > 0


		-- credit 'Clear to' account if Actual is negative (BalType = 1)
		INSERT INTO dbo.tblGlJrnl (PostRun, EntryDate, TransDate, CompId, [Desc], SourceCode, 
			AcctID, CreditAmt, Period, [Year], AllocateYn, CurrencyID, CreditAmtFgn, ExchRate)
			SELECT @PostRun, @EntryDate, @WrkStnDate, @CompId, 'Step ' + CONVERT(nvarchar(3), @Steps), 'CL', h.ClearToAcct
				, -SUM(d.ActualBase), @FiscalPeriod, @FiscalYear, 0, h.CurrencyID, -SUM(d.Actual) 
				, SUM(d.Actual) / SUM(d.ActualBase)
			FROM dbo.tblGlAcctHdr h 
			INNER JOIN dbo.tblGlAcctDtl d on h.AcctId = d.AcctId
			WHERE h.ClearToAcct IS NOT NULL 
				AND h.BalType = 1 
				AND h.ClearToStep = @Steps 
				AND d.[Year] = @FiscalYear 
			GROUP BY h.ClearToAcct, h.CurrencyID 
			HAVING SUM(d.ActualBase) < 0 OR SUM(d.Actual) < 0

		-- move to the next step
		SELECT @Steps = @Steps + 1
	END

	--Reset the gl accounts status
	UPDATE dbo.tblGlAcctHdr SET [Status] = t.Status
	FROM dbo.tblGlAcctHdr 
	INNER JOIN #tmpGlAcct t ON dbo.tblGlAcctHdr.AcctId = t.AcctId
	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlClearClose_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlClearClose_proc';


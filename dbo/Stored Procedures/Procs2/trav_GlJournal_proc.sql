
CREATE PROCEDURE dbo.trav_GlJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = 'USD',
@FiscalYear smallint = 2008,
@PrintOption tinyint = 2, --0, posted; 1, unposted; 2 = all;
@SortOrder nvarchar(80) = '1,2,3',
@SortOption tinyint = 0--0, EntryNum; 1, AcctId(Segment values); 2, SourceCode;
AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @sql nvarchar(1100)
	DECLARE @SortString nvarchar(255)
	DECLARE @ctr int

	--build the sort order field list
	IF @SortOption = 1
	BEGIN
		SET @SortString = 'h.AcctId'
		IF @SortOrder <> ''
		BEGIN
			SET @SortString = ''
		
			WHILE CHARINDEX(',',@SortOrder) <> 0
			BEGIN
				SET @ctr = CHARINDEX(',',@SortOrder)
				IF LEN(@SortString) > 0 SET @SortString = @SortString + ' + '
				SET @SortString = @SortString + 'h.Segment' + SUBSTRING(@SortOrder, 1, @ctr - 1)
				SET @SortOrder = RIGHT(@SortOrder,LEN(@SortOrder) - @ctr )
			END
			SET @SortString = @SortString + ' + h.Segment' + @SortOrder
		END
	END
	ELSE
	BEGIN
		SELECT @SortString = CASE @SortOption WHEN 0 THEN 'j.EntryNum' WHEN 2 THEN 'j.SourceCode' ELSE 'h.AcctId' END
	END

	SET @sql = 'SELECT ' + @SortString + ' As SortOrder, j.EntryNum, j.EntryDate, j.TransDate, j.PostedYn,'
	SET @sql = @sql + 'j.[Desc],j.SourceCode, j.Reference, j.AcctId, j.Period, j.[Year], j.AllocateYn, j.ChkRecon,'
	SET @sql = @sql + 'j.CashFlow,CASE WHEN ' + CAST(@PrintAllInBase AS nvarchar) + ' = 1 THEN j.DebitAmt ELSE j.DebitAmtfgn END AS DebitAmt,'
	SET @sql = @sql + 'CASE WHEN ' + CAST(@PrintAllInBase AS nvarchar) + ' = 1 THEN j.CreditAmt ELSE j.CreditAmtfgn END AS CreditAmt '
	SET @sql = @sql + 'FROM #tmpJournalList t INNER JOIN dbo.tblGlJrnl j ON t.EntryNum = j.EntryNum '
	SET @sql = @sql + 'INNER JOIN dbo.trav_GlAccountMaskedId_view h ON j.AcctId = h.AcctId '
	SET @sql = @sql + 'WHERE j.[Year] = ' + CAST(@FiscalYear AS nvarchar) + ' AND (' + CAST(@PrintAllInBase AS nvarchar) + ' = 1 OR j.CurrencyId = '''
	SET @sql = @sql + CAST(@ReportCurrency AS nvarchar) + ''')	AND j.PostedYN = CASE ' + CAST(@PrintOption AS nvarchar) + ' WHEN 0 THEN -1 WHEN 1 THEN 0 ELSE j.PostedYN END'

	EXECUTE (@sql)	

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlJournal_proc';


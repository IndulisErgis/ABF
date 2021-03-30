
CREATE PROCEDURE dbo.trav_GlChartOfAccountsList_proc
@SortOrder nvarchar(max) = '1,2,3'

AS
SET NOCOUNT ON
BEGIN TRY

	DECLARE @sql nvarchar (max)
	DECLARE @SortString nvarchar (max)
	DECLARE @ctr smallint

	-- build the sort order field list
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

	-- build sql to return results
	SET @sql = 'SELECT ' + @SortString + ' AS SortOrder'
	SET @sql = @sql + ', h.AcctId, h.[Desc], h.AcctTypeId, h.ClearToAcct, h.ClearToStep'
	SET @sql = @sql + ', h.ConsolToAcct, h.ConsolToStep, t.AcctCode, h.Status, h.CurrencyID'
	SET @sql = @sql + ' FROM #tmpAccountList m INNER JOIN dbo.trav_GlAccountHeader_view h ON m.AcctId = h.AcctId '
	SET @sql = @sql + ' INNER JOIN dbo.tblGlAcctType t ON h.AcctTypeId = t.AcctTypeId'
	SET @sql = @sql + ' ORDER BY ' + @SortString

	EXECUTE(@sql)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlChartOfAccountsList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_GlChartOfAccountsList_proc';


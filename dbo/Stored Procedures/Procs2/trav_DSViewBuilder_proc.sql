
CREATE PROCEDURE dbo.trav_DSViewBuilder_proc
@TableName NVARCHAR(255) --name of the table to base the view upon

AS
SET NOCOUNT ON
BEGIN TRY

	Create table #EntityProperty
	(
		[Name] nvarchar(max), --Name of the entity property
		[Type] nvarchar(max) --SQL datatype (i.e. int, nvarchar(10))
	)

	--use dynamic SQL to enable QUOTED_IDENTIFIER for XML processing
	Declare @nsql nvarchar(255)
	SET @nsql = 'SET QUOTED_IDENTIFIER ON;
		Insert Into #EntityProperty ([Name], [Type])
		select m.FieldName, m.FType
		From dbo.trav_DSViewBuilder_view m
		Where m.EntityName = @TableName'
	Exec sp_executesql @nsql, N'@TableName nvarchar(255)', @TableName

	--build a list of columns in the table
	CREATE TABLE #TableColumns (ColumnName nvarchar(max), IsPrimary bit)

	--use the SQL metadata to identify all the columns 
	INSERT INTO #TableColumns (ColumnName, IsPrimary)
	SELECT c.Name, MAX(CAST(ISNULL(i.is_primary_key, 0) AS tinyint))
	FROM sys.objects o 
	INNER JOIN sys.columns c ON o.object_id = c.object_id 
	Left JOIN sys.index_columns ic ON c.object_id = ic.object_id AND c.column_id = ic.column_id
	LEFT JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
	WHERE o.[Name] = @TableName
		AND NOT(c.[name] IN ('ts', 'CF')) --exclude the ts (timestamp) and CF columns
	GROUP BY c.Name

	--setup constants used for formatting
	DECLARE @crlf nvarchar(2)
	DECLARE @tab nvarchar(1)
	SELECT @crlf = nchar(13) + nchar(10), @tab = nchar(9)

	--build the view name
	DECLARE @viewName nvarchar(255)
	SELECT @viewName = 'trav_' + @TableName + '_View'

	--Build lists of table, primary key and property column names
	DECLARE @keyColumns nvarchar(max)
	DECLARE @join nvarchar(max)
	DECLARE @allColumns nvarchar(max)
	DECLARE @propColumns nvarchar(max)
	DECLARE @propColumnsAlias nvarchar(max)
	DECLARE @propColumnsCast nvarchar(max)
	DECLARE @sql nvarchar(max)

	--initialize variables
	SELECT @keyColumns = ''
		, @join = ''
		, @allColumns = ''
		, @propColumns = ''
		, @propColumnsAlias = ''
		, @propColumnsCast = ''

	--table columns 
	SELECT @keyColumns = @keyColumns + CASE WHEN [IsPrimary] = 1 THEN ', {t}[' + [ColumnName] + ']' + @crlf ELSE '' END
		, @join = @join + CASE WHEN [IsPrimary] = 1 THEN ' AND {t}[' + [ColumnName] + '] = {e}[' + [ColumnName] + ']' ELSE '' END
		, @allColumns = @allColumns + ', {t}[' + [ColumnName] + ']' + @crlf
		FROM #TableColumns

	--entity property columns
	SELECT @propColumns = @propColumns + ', {e}[' + [Name] + ']' + @crlf
		, @propColumnsAlias = @propColumnsAlias + ', {e}[cf_' + [Name] + ']' + @crlf
		, @propColumnsCast = @propColumnsCast + ', Cast({e}[' + [Name] + '] As ' + Max([Type]) + ') AS [cf_' + [Name] + ']' + @crlf
		FROM #EntityProperty
		GROUP BY [Name]

	--trim the starting comma FROM each string
	SELECT @keyColumns = SUBSTRING(@keyColumns, 3, LEN(@keyColumns))
		, @join = SUBSTRING(@join, 5, LEN(@join))
		, @allColumns = SUBSTRING(@allColumns, 3, LEN(@allColumns))
		, @propColumns = SUBSTRING(@propColumns, 3, LEN(@propColumns))
		, @propColumnsAlias = SUBSTRING(@propColumnsAlias, 3, LEN(@propColumnsAlias))
		, @propColumnsCast = SUBSTRING(@propColumnsCast, 3, LEN(@propColumnsCast))

	--construct a simple view when no entity properties are defined
	--	otherwise use XQuery methods to extract the entity properties 
	--	and perform a PIVOT to crosstab the results
	If (SELECT Count(*) FROM #EntityProperty) = 0
	Begin
		SELECT @sql = 'SELECT ' + Replace(@allColumns, '{t}', 't.') + ' FROM dbo.[' + @TableName + '] t'
	End
	Else
	Begin
		SELECT @sql = 'SELECT ' + Replace(@allColumns, '{t}', 't.')
			+ ', ' + Replace(@propcolumnsAlias, '{e}', 'e.')
			+ ' FROM dbo.[' + @TableName + '] t' + @crlf
			+ ' LEFT JOIN' +  + @crlf
			+ ' ( SELECT ' + Replace(Replace(@keyColumns, '{t}', 'pvt.') + ', ' + Replace(@propColumnsCast, '{e}', 'pvt.'), ',', @tab + ',')
			+ @tab + ' FROM' + @crlf
			+ @tab + @tab + Replace(' ( SELECT ' + Replace(@keyColumns, '{t}', 't.') + ', [Name], [Value]', @crlf, '') + @crlf
			+ @tab + @tab + ' FROM' + @crlf
			+ @tab + @tab + @tab + ' ( SELECT ' + Replace(Replace(@keyColumns, '{t}', 't.'), @crlf, '') + @crlf
			+ @tab + @tab + @tab + ' , e.props.value(''./Name[1]'', ''NVARCHAR(max)'') as [Name]' + @crlf
			+ @tab + @tab + @tab + ' , e.props.value(''./Value[1]'', ''NVARCHAR(max)'') as [Value]' + @crlf
			+ @tab + @tab + @tab + ' FROM dbo.[' + @TableName + '] t' + @crlf
			+ @tab + @tab + @tab + ' CROSS APPLY t.CF.nodes(''/ArrayOfEntityPropertyOfString/EntityPropertyOfString'') as e(props)' + @crlf
			+ @tab + @tab + @tab + ' WHERE (e.props.exist(''Name'') = 1) AND (e.props.exist(''Value'') = 1)' + @crlf
			+ @tab + @tab + ' ) t' + @crlf
			+ @tab + ' ) tmp' + @crlf
			+ @tab + ' PIVOT (Max([Value]) FOR [Name] IN (' + Replace(Replace(@propColumns, '{e}', ''), @crlf, '') + ')) AS pvt' + @crlf
			+ ') e on ' + Replace(Replace(@join, '{t}', 't.'), '{e}', 'e.') + @crlf
	End

	--construct a 'create' or 'alter' statement depending upon the existence of the view 
	If EXISTS (SELECT * FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[' + @viewName + ']') AND OBJECTPROPERTY([object_id], N'IsView') = 1)
	Begin
		SELECT @sql = 'ALTER VIEW [dbo].[' + @viewName + ']' + @crlf + 'AS' + @crlf + @sql
	End
	Else
	Begin
		SELECT @sql = 'CREATE VIEW [dbo].[' + @viewName + ']' + @crlf + 'AS' + @crlf + @sql
	End

	--execute the SQL command to create/alter the view
	Exec (@sql)

	--return any errors generated by the execution
	Return @@Error
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DSViewBuilder_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DSViewBuilder_proc';


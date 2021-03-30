
CREATE PROCEDURE dbo.trav_CmContactMethodView_proc
AS
DECLARE @ColumnList AS Nvarchar(max)
DECLARE @Descr AS Nvarchar(255)
DECLARE @curMethodType Cursor

BEGIN TRY
	SET NOCOUNT ON
	
	SET @curMethodType = CURSOR FOR 
		SELECT Descr FROM dbo.tblCmContactMethodType FOR READ ONLY
	SET @ColumnList = N''	
	OPEN @curMethodType
	If @@CURSOR_ROWS <> 0
	BEGIN
		FETCH NEXT FROM @curMethodType INTO @Descr
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @ColumnList = @ColumnList + '[' + @Descr + '],'
			FETCH NEXT FROM @curMethodType INTO @Descr
		End
		CLOSE @curMethodType
	END
	DEALLOCATE @curMethodType
		
			
SET @ColumnList = Case when ISNULL(@ColumnList, '') = '' then @ColumnList + '[' + 'DfltDescr' + ']'  else  LEFT(@ColumnList, LEN(@ColumnList) - 1) end
			
EXEC ('SET QUOTED_IDENTIFIER ON ;
	SELECT c.*, s.Descr AS ContactStatus, r.ContactName AS ReportTo, a.Descr AS DefaultDescription, 
		a.Addr1 AS DefaultAddress1, a.Addr2 AS DefaultAddress2, a.City AS DefaultCity, a.Region AS DefaultRegion, 
		a.Country AS DefaultCountry, a.PostalCode AS DefaultPostalCode, a.[Status] AS DefaultStatus,' + @ColumnList + 
		' FROM #CrmAccessList t INNER JOIN dbo.trav_tblCmContact_view c ON t.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactAddress a ON a.ContactID = c.ID 
		LEFT JOIN dbo.tblCmContactStatus s ON s.ID = c.StatusID 
		LEFT JOIN dbo.tblCmContact r ON c.ReportToID = r.ID LEFT JOIN (SELECT m.ContactID, t.Descr, m.value FROM tblCmContactMethod m INNER JOIN dbo.tblCmContactMethodType t ON m.TypeID = t.ID ) p PIVOT 
	(MAX(value) FOR Descr IN (' + @ColumnList + ')) as pvt ON c.ID = pvt.ContactID WHERE ISNULL(a.Sequence, 0) = 0')

	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactMethodView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_CmContactMethodView_proc';


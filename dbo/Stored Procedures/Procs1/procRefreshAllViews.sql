

CREATE PROC [dbo].[procRefreshAllViews]
AS
SET quoted_identifier off
DECLARE @ObjectName varchar (255)
DECLARE @ObjectName_header varchar (255)
DECLARE tnames_cursor CURSOR FOR SELECT name FROM sysobjects    
WHERE type = 'V' AND uid = 1 
Order By Name
OPEN tnames_cursor
FETCH NEXT FROM tnames_cursor 
INTO @Objectname
WHILE (@@fetch_status <> -1)
BEGIN
    IF (@@fetch_status <> -2)
    BEGIN
        SELECT @ObjectName_header = 'Refreshing ' + @ObjectName
        PRINT @ObjectName_header
        EXEC('sp_refreshview ' + @ObjectName
)    END
    FETCH NEXT FROM tnames_cursor INTO @ObjectName
END
PRINT ' '
SELECT @ObjectName_header = 'ALL VIEWS HAVE BEEN REFRESHED'
PRINT @ObjectName_header
DEALLOCATE tnames_cursor
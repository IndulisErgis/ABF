
CREATE PROCEDURE [dbo].[trav_SmDocumentPurge_proc]                
@PurgeOption tinyint --0;RemoveAll;1;RemoveDuplicate
AS
BEGIN TRY

IF(@PurgeOption = 1) --Remove Duplicate
BEGIN
--Temp table contains all the records selected by the user.
--Remove those records we want to keep from the temp table.
--Keep MAX(ID) records (those are the latest records) group by Function Id, Souce Id, Key Field Name, Key Field Vaue.
	DELETE FROM #DocumentList
    WHERE [DocId] IN
		(SELECT Max(ID) AS ID
		 FROM dbo.tblSmActivity a
			 INNER JOIN dbo.tblSmDocumentStore d ON a.ActivityId = d.ActivityID
			 INNER JOIN #DocumentList t ON d.ID = t.DocId
		 GROUP BY a.FunctionId,
				  d.SourceId,
				  d.KeyFieldName,
				  d.KeyFieldValue)
END   

--Delete all the records matching those in the temp table
DELETE d
FROM dbo.tblSmDocumentStore d
INNER JOIN #DocumentList t ON d.ID = t.DocId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmDocumentPurge_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmDocumentPurge_proc';



CREATE PROCEDURE [dbo].[trav_InGetLastGoodTagNumber_proc]
@BatchID  pBatchID = 'abc'
AS
SET NOCOUNT ON
BEGIN TRY

SELECT ISNULL(MAX(TagNum) ,0)
FROM (
SELECT TagNum from dbo.tblInPhysCount WHERE BatchID = @BatchID AND TagNum IS NOT NULL
UNION ALL 
SELECT d.TagNum 
FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum
WHERE c.BatchID = @BatchID  AND d.TagNum IS NOT NULL) Tag


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InGetLastGoodTagNumber_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InGetLastGoodTagNumber_proc';


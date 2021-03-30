CREATE PROCEDURE Alp_DeleteIMPQuoteItems (@pImpItemIds Alp_tblINTTableType READONLY)AS
BEGIN
	DECLARE @totalItemCount int;  
	DECLARE @importedItemCount int;  
	DECLARE @status int=2; 

	SELECT ImportMainId, ItemCount= COUNT (*) INTO #t1 FROM Alp_tblIMPItem 
	WHERE  ImportItemId in(select * from @pImpItemIds) AND IsImported=0 GROUP BY ImportMainId  

	UPDATE Alp_tblImpMain SET Source_PartCnt =Source_PartCnt- ItemCount 
	FROM Alp_tblImpMain a  INNER JOIN #t1 b ON a.ImportMainId=b.ImportMainId

	DELETE FROM Alp_tblIMPItem WHERE ImportItemId in (select * from @pImpItemIds )

	SELECT  @totalItemCount =COUNT(*)  ,  @importedItemCount =SUM(a.IsImported)   
	FROM Alp_tblIMPItem  a INNER JOIN Alp_tblIMPMain b ON a.ImportMainId =b.ImportMainId  
	WHERE a.ImportMainId in (SELECT ImportMainId FROM #t1)
     
	IF (@importedItemCount=0)  
		SET @status = 0  
	ELSE IF (@importedItemCount >0 AND @importedItemCount <@totalItemCount )  
		SET @status = 1  
	ELSE IF (@totalItemCount =@importedItemCount )  
		SET @status = 2  
    
	UPDATE Alp_tblIMPMain SET Alp_tblIMPMain.Status = @status  
	FROM Alp_tblImpMain a  INNER JOIN #t1 b ON a.ImportMainId=b.ImportMainId
   
	DROP TABLE #t1
END
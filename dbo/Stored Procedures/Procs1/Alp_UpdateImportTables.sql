
CREATE Procedure [dbo].[Alp_UpdateImportTables] ( @pImportItemId int,@pTicketId int,@pModifiedBy varchar(16))AS
 DECLARE @totalItemCount int;
 DECLARE @importedItemCount int;
 DECLARE @status int;
 DECLARE @importMainId int;
 BEGIN
		UPDATE Alp_tblIMPItem SET IsImported=1,TicketId =@pTicketId,ModifiedBy= @pModifiedBy,ModifiedDate=GETDATE() WHERE ImportItemId=@pImportItemId
		
		UPDATE Alp_tblIMPMain SET Source_PartCnt=Source_PartCnt -1
		FROM Alp_tblIMPMain a INNER JOIN Alp_tblIMPItem b ON a.ImportMainId=b.ImportMainId
		WHERE b.ImportItemId =@pImportItemId
		
		SELECT @importMainId= a.ImportMainId
		FROM Alp_tblIMPMain a INNER JOIN Alp_tblIMPItem b ON a.ImportMainId=b.ImportMainId
		WHERE b.ImportItemId =@pImportItemId
		
		SELECT  @totalItemCount =COUNT(*)  ,  @importedItemCount =SUM(a.IsImported) 
		FROM Alp_tblIMPItem  a INNER JOIN Alp_tblIMPMain b ON a.ImportMainId =b.ImportMainId
		WHERE a.ImportMainId=@importMainId
		 
		IF (@importedItemCount=0)
	 		SET @status = 0
	 	ELSE IF (@importedItemCount >0 AND @importedItemCount <@totalItemCount )
			SET @status = 1
		ELSE IF (@totalItemCount =@importedItemCount )
			SET @status = 2
	 
		
		UPDATE Alp_tblIMPMain SET Alp_tblIMPMain.Status = @status
		FROM Alp_tblIMPMain  a INNER JOIN Alp_tblIMPItem b ON a.ImportMainId =b.ImportMainId 
		WHERE b.ImportItemId = @pImportItemId
		
 END
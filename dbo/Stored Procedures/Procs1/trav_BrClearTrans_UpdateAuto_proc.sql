
CREATE PROCEDURE dbo.trav_BrClearTrans_UpdateAuto_proc 
@BankId nvarchar(10),
@StatementId bigint =0
AS
BEGIN TRY
DECLARE @i tinyint,  @Descr as nvarchar(35), @SourceId nvarchar (10), @Reference nvarchar (15), 
	@EntryNum int, @Amount decimal(28,10), @TransDate datetime, @StartTime datetime
	
SELECT @i = 1

DECLARE curClearTransaction CURSOR FOR
	SELECT  Descr, Reference, SourceId, TransDate, SIGN(ISNULL(TransType,1)) * Amount AS Amount
	FROM dbo.tblBrClearedTrans
	WHERE BankId = @BankId AND (ClearedEntryNum IS NULL OR ClearedEntryNum = 0) 

--Loop to do 5 level matching		
WHILE @i < 6 
BEGIN
	SET @StartTime = GETDATE()
	OPEN curClearTransaction
	FETCH NEXT FROM curClearTransaction INTO @Descr, @Reference, @SourceId, @TransDate, @Amount
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		--Amount must match
		SET @EntryNum = 0
		IF (@i = 1) --Match SourceId, Description, Reference and TransDate
		BEGIN
			IF (ISNULL(@SourceId,'') != '' AND ISNULL(@Reference,'') != '' AND ISNULL(@Descr,'') != '')
			BEGIN
				SELECT TOP 1 @EntryNum = EntryNum
				FROM tblBrMaster 
				WHERE BankId = @BankId AND ClearedYn = 0 AND VoidStop = 0 AND AmountFgn = @Amount 
					AND SourceId = @SourceId AND TransDate = @TransDate AND Reference = @Reference AND Descr = @Descr
				ORDER BY TransDate
				
				IF @EntryNum > 0 -- Found Match
				BEGIN
					UPDATE dbo.tblBrMaster SET ClearedYn = 1, StatementID=@StatementId
					WHERE EntryNum  = @EntryNum
					
					UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum = @EntryNum  WHERE CURRENT OF curClearTransaction      
				END
			END
		END
		ELSE IF (@i = 2) --Match 3 of SourceId, Description, Reference and TransDate, SourceId must match if it has value
		BEGIN
			IF ( CASE ISNULL(@SourceId,'') WHEN '' THEN 0 ELSE 1 END + CASE ISNULL(@Reference,'') WHEN '' THEN 0 ELSE 1 END 
				+ CASE ISNULL(@Descr,'') WHEN '' THEN 0 ELSE 1 END ) = 2
			BEGIN
				SELECT TOP 1 @EntryNum = EntryNum
				FROM tblBrMaster 
				WHERE BankId = @BankId AND ClearedYn = 0 AND VoidStop = 0 AND AmountFgn = @Amount 
					AND ((ISNULL(@SourceId,'') != '' AND SourceId = @SourceId AND ((TransDate = @TransDate AND Reference = @Reference) OR (TransDate = @TransDate AND Descr = @Descr) OR (Reference = @Reference AND Descr = @Descr)))
						OR (ISNULL(@SourceId,'') = '' AND TransDate = @TransDate AND Reference = @Reference AND Descr = @Descr))
				ORDER BY TransDate
				
				IF @EntryNum > 0 -- Found Match
				BEGIN
					UPDATE dbo.tblBrMaster SET ClearedYn = 1, StatementID=@StatementId
					WHERE EntryNum  = @EntryNum
					
					UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum = @EntryNum  WHERE CURRENT OF curClearTransaction       
				END	
			END
		END
		ELSE IF (@i = 3)--Match 2 of SourceId, Description, Reference and TransDate, SourceId must match if it has value
		BEGIN
			IF ( CASE ISNULL(@SourceId,'') WHEN '' THEN 0 ELSE 1 END + CASE ISNULL(@Reference,'') WHEN '' THEN 0 ELSE 1 END 
				+ CASE ISNULL(@Descr,'') WHEN '' THEN 0 ELSE 1 END ) = 1
			BEGIN
				SELECT TOP 1 @EntryNum = EntryNum
				FROM tblBrMaster 
				WHERE BankId = @BankId AND ClearedYn = 0 AND VoidStop = 0 AND AmountFgn = @Amount 
					AND ((ISNULL(@SourceId,'') != '' AND SourceId = @SourceId AND (TransDate = @TransDate OR Reference = @Reference OR Descr = @Descr))
						OR (ISNULL(@SourceId,'') = '' AND ((TransDate = @TransDate AND Reference = @Reference) OR (TransDate = @TransDate AND Descr = @Descr) OR (Reference = @Reference AND Descr = @Descr))))
				ORDER BY TransDate
				
				IF @EntryNum > 0 -- Found Match
				BEGIN
					UPDATE dbo.tblBrMaster SET ClearedYn = 1, StatementID=@StatementId
					WHERE EntryNum  = @EntryNum
					
					UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum = @EntryNum  WHERE CURRENT OF curClearTransaction   
				END	
			END
		END
		ELSE IF (@i = 4)--Match 1 of SourceId, Description, Reference and TransDate, SourceId must match if it has value
		BEGIN
			SELECT TOP 1 @EntryNum = EntryNum
			FROM tblBrMaster 
			WHERE BankId = @BankId AND ClearedYn = 0 AND VoidStop = 0 AND AmountFgn = @Amount 
				AND ((ISNULL(@SourceId,'') != '' AND SourceId = @SourceId) OR 
					(ISNULL(@SourceId,'') = '' AND (TransDate = @TransDate OR Reference = @Reference OR Descr = @Descr)))
			ORDER BY TransDate
			
			IF @EntryNum > 0 -- Found Match
			BEGIN
				UPDATE dbo.tblBrMaster SET ClearedYn = 1, StatementID=@StatementId
				WHERE EntryNum  = @EntryNum
				
				UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum = @EntryNum  WHERE CURRENT OF curClearTransaction        
			END		
		END
		ELSE IF (@i = 5)
		BEGIN
			SELECT TOP 1 @EntryNum = EntryNum
			FROM tblBrMaster 
			WHERE BankId = @BankId AND ClearedYn = 0 AND VoidStop = 0 AND AmountFgn = @Amount 
				AND (ISNULL(@SourceId,'') = '' OR SourceId = @SourceId) -- SourceId has no value or SourceId has match in master
			ORDER BY TransDate
			
			IF @EntryNum > 0 -- Found Match
			BEGIN
				UPDATE dbo.tblBrMaster SET ClearedYn = 1, StatementID=@StatementId
				WHERE EntryNum  = @EntryNum
				
				UPDATE dbo.tblBrClearedTrans SET ClearedEntryNum = @EntryNum  WHERE CURRENT OF curClearTransaction   
			END					
		END
		FETCH NEXT FROM curClearTransaction INTO @Descr, @Reference, @SourceId, @TransDate, @Amount
	END
	CLOSE curClearTransaction
	
	SET @i = @i + 1
END 
DEALLOCATE curClearTransaction

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrClearTrans_UpdateAuto_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_BrClearTrans_UpdateAuto_proc';


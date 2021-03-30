CREATE Procedure [dbo].[trvsp_NextTransID]  
@FunctionID varchar(10),  
@IsInt bit =0,  --true if transid is of type int  
@TransID pTransID OUT   
AS  
set nocount on  
DECLARE @NextID int, @TransCnt int, @Done bit   
BEGIN TRANSACTION  
	SELECT @NextID = NextID FROM dbo.tblSmTransID (TABLOCKX)   
	WHERE FunctionID = @FunctionID  
print'A'
print @NextID
IF (@NextID IS NULL)   
BEGIN  
 INSERT INTO dbo.tblSmTransID (FunctionID, NextID) VALUES (@FunctionID,1)  
 SELECT @NextID = 1  
END  

IF (@NextID > 99999999) SET @NextID = 1  
	SET @Done = 0  
	WHILE (@Done = 0)  
	BEGIN  
		SET @TransCnt=0  
		IF @IsInt=0  
		BEGIN  
Print 'B'		
		SET @TransID = CONVERT(varchar(8), @NextID)  
		
		SET @TransID = REPLICATE('0',8-DATALENGTH(@TransID)) + @TransID  
		print @TransID
		END  
 
		IF @FunctionID = 'AR'  
		SELECT @TransCnt = Count(*) FROM dbo.tblArTransHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'AP'  
		SELECT @TransCnt = Count(*) FROM dbo.tblApTransHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'SO'  
		SELECT @TransCnt = Count(*) FROM dbo.tblSoTransHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'PO'  
		SELECT @TransCnt = Count(*) FROM dbo.tblPoTransHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'BR'  
		SELECT @TransCnt = Count(*) FROM dbo.tblBrJrnlHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'BM'  
		SELECT @TransCnt = Count(*) FROM dbo.tblBmWorkOrder WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'FA'  
		SELECT @TransCnt = Count(*) FROM dbo.tblFaRetire WHERE RetirementID = @NextID  
		ELSE IF @FunctionID = 'INTRANS'  --uses int type  
		SELECT @TransCnt = Count(*) FROM dbo.tblInTrans WHERE TransID = @NextID  
		ELSE IF @FunctionID = 'INXFER'  
		SELECT @TransCnt = Count(*) FROM dbo.tblInXfers WHERE TransID = @NextID  
		ELSE IF @FunctionID = 'JCTRANS'  
		SELECT @TransCnt = Count(*) FROM dbo.tblJcTransHeader WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'JCHIST'  
		SELECT @TransCnt = Count(*) FROM dbo.tblJcTransHistory WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'JCHISTADJ'  
		SELECT @TransCnt = Count(*) FROM dbo.tblJcTransHistAdj WHERE TransID = @TransID  
		ELSE IF @FunctionID = 'MP'  
		SELECT @TransCnt = Count(*) FROM dbo.tblMpOrder WHERE OrderNo = @TransID  
	ELSE  
	SET @TransCnt = 0  
   
	IF (@TransCnt > 0)   
	Begin
		SELECT @NextID = @NextID + 1   
		print 'D'
		print @NextID
	End	
	ELSE  
		SELECT @Done = 1  
END  
UPDATE dbo.tblSmTransID SET NextID = @NextID + 1   
 WHERE FunctionID = @FunctionID  
IF @IsInt=1  
 SET @TransID = cast(@NextID as varchar(8))  
	print 'E'
  print @TransID 
COMMIT TRANSACTION
CREATE Procedure [dbo].[ALP_qryAppendSysAudit]  
@AuditType tinyint,  
@FunctionId nvarchar(50),  
@ObjectId  nvarchar(255),  
@KeyValue nvarchar(255)=null,  
@SessionId varchar(14),  
@UserId varchar(50),  
@EventData ntext =null  
--modified to take Alpine userID length of 50 from 20.  But, will insert only first 20 into the Trav sys audit table
AS  
SET NOCOUNT ON  
INSERT INTO dbo.tblSysAudit   
(AuditType,FunctionId,ObjectId,KeyValue,SessionId,UserId,[EventData])  
VALUES(@AuditType,@FunctionId,@ObjectId,@KeyValue,@SessionId,LEFT(@UserId,20),@EventData)